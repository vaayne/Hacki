import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hacki/config/locator.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/repositories/repositories.dart';

part 'translation_state.dart';

/// Holds the translation of each item keyed by its id, so a translated comment
/// or story stays translated as the user scrolls.
///
/// Requests are coalesced: items asking to be translated are queued and sent
/// in a single batched request (size from the translation batch size
/// preference) rather than one request each. Results are also cached on disk
/// so a thread reopened later is translated for free.
class TranslationCubit extends Cubit<TranslationState> with Loggable {
  TranslationCubit({
    PreferenceRepository? preferenceRepository,
    TranslationRepository? translationRepository,
    SembastRepository? sembastRepository,
  }) : _preferenceRepository =
           preferenceRepository ?? locator.get<PreferenceRepository>(),
       _translationRepository =
           translationRepository ?? locator.get<TranslationRepository>(),
       _sembastRepository =
           sembastRepository ?? locator.get<SembastRepository>(),
       super(const TranslationState.init());

  final PreferenceRepository _preferenceRepository;
  final TranslationRepository _translationRepository;
  final SembastRepository _sembastRepository;

  final List<_PendingItem> _pending = <_PendingItem>[];
  Timer? _flushTimer;
  bool _flushing = false;

  static const Duration _debounce = Duration(milliseconds: 150);

  /// Toggles translation display for the current thread. Cached translations
  /// are kept so flipping it back on is instant.
  void toggle() => emit(state.copyWith(active: !state.active));

  /// Requests translation of the item with [id]. Returns immediately; the
  /// actual request happens in a batch. Safe to call repeatedly — items already
  /// translating or translated are ignored.
  Future<void> translate({
    required int id,
    required String text,
    required String targetLanguage,
  }) async {
    final TranslationStatus status = state.of(id).status;
    if (status == TranslationStatus.inProgress ||
        status == TranslationStatus.success) {
      return;
    }

    // Mark in-progress synchronously so concurrent rebuilds don't re-enqueue.
    emit(state.updated(id, TranslationStatus.inProgress));

    final String key = _cacheKey(targetLanguage, id);
    final String? cached = await _sembastRepository.getCachedTranslation(
      key: key,
    );
    if (cached != null) {
      emit(state.updated(id, TranslationStatus.success, text: cached));
      return;
    }

    _pending.add(
      _PendingItem(id: id, text: text, targetLanguage: targetLanguage),
    );
    _flushTimer?.cancel();
    _flushTimer = Timer(_debounce, _flush);
  }

  Future<void> _flush() async {
    _flushTimer?.cancel();
    if (_flushing || _pending.isEmpty) return;
    _flushing = true;

    try {
      final String? apiKey = await _preferenceRepository.translationApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        for (final _PendingItem item in _pending) {
          emit(state.updated(item.id, TranslationStatus.missingApiKey));
        }
        _pending.clear();
        return;
      }

      final int batchSize = await _preferenceRepository.translationBatchSize;
      final String baseUrl = await _preferenceRepository.translationBaseUrl;
      final String model = await _preferenceRepository.translationModel;

      while (_pending.isNotEmpty) {
        final List<_PendingItem> batch = _pending
            .take(batchSize)
            .toList(growable: false);
        _pending.removeRange(0, batch.length);

        try {
          final List<String> results = await _translationRepository
              .translateBatch(
                texts: batch.map((_PendingItem e) => e.text).toList(),
                targetLanguage: batch.first.targetLanguage,
                apiKey: apiKey,
                baseUrl: baseUrl,
                model: model,
              );
          for (int i = 0; i < batch.length; i++) {
            final _PendingItem item = batch[i];
            emit(
              state.updated(
                item.id,
                TranslationStatus.success,
                text: results[i],
              ),
            );
            await _sembastRepository.cacheTranslation(
              key: _cacheKey(item.targetLanguage, item.id),
              translation: results[i],
            );
          }
        } on AppException catch (e) {
          logError(e.message);
          for (final _PendingItem item in batch) {
            emit(state.updated(item.id, TranslationStatus.failure));
          }
        }
      }
    } finally {
      _flushing = false;
    }

    if (_pending.isNotEmpty) {
      _flushTimer = Timer(_debounce, _flush);
    }
  }

  String _cacheKey(String targetLanguage, int id) => '$targetLanguage:$id';

  @override
  Future<void> close() {
    _flushTimer?.cancel();
    return super.close();
  }

  @override
  String get logIdentifier => 'TranslationCubit';
}

class _PendingItem {
  const _PendingItem({
    required this.id,
    required this.text,
    required this.targetLanguage,
  });

  final int id;
  final String text;
  final String targetLanguage;
}
