import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';

/// Resolves a tip index (see `Constants.randomTipIndex`) to its localized
/// string. Falls back to the first tip for out-of-range indices.
String localizedTip(BuildContext context, int index) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return switch (index) {
    0 => l10n.tip1,
    1 => l10n.tip2,
    2 => l10n.tip3,
    3 => l10n.tip4,
    4 => l10n.tip5,
    5 => l10n.tip6,
    6 => l10n.tip7,
    7 => l10n.tip8,
    8 => l10n.tip9,
    9 => l10n.tip10,
    10 => l10n.tip11,
    11 => l10n.tip12,
    _ => l10n.tip1,
  };
}
