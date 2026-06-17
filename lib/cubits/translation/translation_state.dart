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
  const TranslationState({required this.translations});

  const TranslationState.init()
    : translations = const <int, ItemTranslation>{};

  final Map<int, ItemTranslation> translations;

  /// Translation of [id], or an idle placeholder when none exists yet.
  ItemTranslation of(int id) =>
      translations[id] ??
      const ItemTranslation(status: TranslationStatus.idle);

  TranslationState updated(int id, TranslationStatus status, {String? text}) {
    return TranslationState(
      translations: <int, ItemTranslation>{
        ...translations,
        id: ItemTranslation(status: status, text: text),
      },
    );
  }

  TranslationState removed(int id) {
    return TranslationState(
      translations: <int, ItemTranslation>{...translations}..remove(id),
    );
  }

  @override
  List<Object?> get props => <Object?>[translations];
}
