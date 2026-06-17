import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';

enum MaxOfflineStoriesCount {
  ten(20, '20'),
  fifty(50, '50'),
  hundred(100, '100'),
  twoHundred(200, '200'),
  all(null, 'All');

  const MaxOfflineStoriesCount(this.count, this.label);

  final int? count;
  final String label;

  /// Localized label; only [all] is translated, numeric values stay as-is.
  String localizedLabel(BuildContext context) {
    return switch (this) {
      MaxOfflineStoriesCount.all =>
        AppLocalizations.of(context).maxOfflineStoriesCountAll,
      _ => label,
    };
  }
}
