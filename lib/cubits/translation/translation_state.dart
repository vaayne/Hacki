part of 'translation_cubit.dart';

enum TranslationStatus { idle, inProgress, success, missingApiKey, failure }

class ItemTranslation extends Equatable {
  const ItemTranslation({required this.status, this.text});

  final TranslationStatus status;
  final String? text;

  @override
  List<Object?> get props => <Object?>[status, text];
}

class TranslationState extends Equatable {
  const TranslationState({required this.translations, required this.active});

  const TranslationState.init()
    : translations = const <int, ItemTranslation>{},
      active = false;

  final Map<int, ItemTranslation> translations;

  /// Whether translations are shown for the current thread. Toggled from the
  /// thread app bar; individual items translate themselves while it is on.
  final bool active;

  /// Translation of [id], or an idle placeholder when none exists yet.
  ItemTranslation of(int id) =>
      translations[id] ??
      const ItemTranslation(status: TranslationStatus.idle);

  TranslationState copyWith({
    Map<int, ItemTranslation>? translations,
    bool? active,
  }) {
    return TranslationState(
      translations: translations ?? this.translations,
      active: active ?? this.active,
    );
  }

  TranslationState updated(int id, TranslationStatus status, {String? text}) {
    return copyWith(
      translations: <int, ItemTranslation>{
        ...translations,
        id: ItemTranslation(status: status, text: text),
      },
    );
  }

  @override
  List<Object?> get props => <Object?>[translations, active];
}
