import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';

/// Languages the user can pick in settings. [system] follows the device
/// locale; the others force the corresponding [Locale].
enum AppLanguage {
  system(null),
  english(Locale('en')),
  chinese(Locale('zh'));

  const AppLanguage(this.locale);

  final Locale? locale;

  /// Localized label shown in the language selector.
  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.chinese => l10n.languageChinese,
    };
  }
}
