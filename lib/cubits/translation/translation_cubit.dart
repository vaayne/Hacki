import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hacki/config/locator.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/repositories/repositories.dart';

part 'translation_state.dart';

/// Holds the translation of each item keyed by its id, so a translated comment
/// or story stays translated as the user scrolls without refetching.
class TranslationCubit extends Cubit<TranslationState> with Loggable {
  TranslationCubit({
    PreferenceRepository? preferenceRepository,
    TranslationRepository? translationRepository,
  }) : _preferenceRepository =
           preferenceRepository ?? locator.get<PreferenceRepository>(),
       _translationRepository =
           translationRepository ?? locator.get<TranslationRepository>(),
       super(const TranslationState.init());

  final PreferenceRepository _preferenceRepository;
  final TranslationRepository _translationRepository;

  /// Translates [text] of the item with [id] into [targetLanguage].
  ///
  /// Re-entrancy and configuration errors are handled here so callers only
  /// have to render the resulting [ItemTranslation].
  Future<void> translate({
    required int id,
    required String text,
    required String targetLanguage,
  }) async {
    if (state.of(id).status == TranslationStatus.inProgress) return;

    // Mark in-progress synchronously so concurrent rebuilds don't re-trigger
    // the request during the awaits below.
    emit(state.updated(id, TranslationStatus.inProgress));

    final String? apiKey = await _preferenceRepository.translationApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      emit(state.updated(id, TranslationStatus.missingApiKey));
      return;
    }

    try {
      final String result = await _translationRepository.translate(
        text: text,
        targetLanguage: targetLanguage,
        apiKey: apiKey,
        baseUrl: await _preferenceRepository.translationBaseUrl,
        model: await _preferenceRepository.translationModel,
      );
      emit(state.updated(id, TranslationStatus.success, text: result));
    } on AppException catch (e) {
      logError(e.message);
      emit(state.updated(id, TranslationStatus.failure));
    }
  }

  /// Toggles translation display for the current thread. Cached translations
  /// are kept so flipping it back on is instant.
  void toggle() => emit(state.copyWith(active: !state.active));

  @override
  String get logIdentifier => 'TranslationCubit';
}
