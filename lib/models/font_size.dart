import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/styles/styles.dart';

enum FontSize {
  small('Small', TextDimens.pt15),
  regular('Regular', TextDimens.pt16),
  large('Large', TextDimens.pt17),
  xlarge('XLarge', TextDimens.pt18),
  xxlarge('XXLarge', TextDimens.pt19);

  const FontSize(this.description, this.fontSize);

  final String description;
  final double fontSize;

  /// Localized label shown in the font size selector.
  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      FontSize.small => l10n.fontSizeSmall,
      FontSize.regular => l10n.fontSizeRegular,
      FontSize.large => l10n.fontSizeLarge,
      FontSize.xlarge => l10n.fontSizeXLarge,
      FontSize.xxlarge => l10n.fontSizeXXLarge,
    };
  }
}
