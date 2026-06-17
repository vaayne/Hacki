import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/discoverable_feature.dart';

/// Localized [DiscoverableFeature.title]; falls back to the English title for
/// features without a translation.
String localizedFeatureTitle(BuildContext context, DiscoverableFeature f) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  switch (f.featureId) {
    case 'add_story_to_fav_list':
      return l10n.featureFavStoryTitle;
    case 'settings_shortcut_on_item_screen':
      return l10n.featureGoToSettingsTitle;
    case 'log_in':
      return l10n.featureLoginTitle;
    case 'pin_to_top':
      return l10n.featurePinStoryTitle;
    case 'jump_up_button_with_long_press':
      return l10n.featureJumpUpTitle;
    case 'jump_down_button_with_long_press':
      return l10n.featureJumpDownTitle;
    case 'search_in_thread':
      return l10n.featureSearchInThreadTitle;
    default:
      return f.title;
  }
}

/// Localized [DiscoverableFeature.description]; falls back to the English
/// description for features without a translation.
String localizedFeatureDescription(
  BuildContext context,
  DiscoverableFeature f,
) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  switch (f.featureId) {
    case 'add_story_to_fav_list':
      return l10n.featureFavStoryDesc;
    case 'settings_shortcut_on_item_screen':
      return l10n.featureGoToSettingsDesc;
    case 'log_in':
      return l10n.featureLoginDesc;
    case 'pin_to_top':
      return l10n.featurePinStoryDesc;
    case 'jump_up_button_with_long_press':
      return l10n.featureJumpUpDesc;
    case 'jump_down_button_with_long_press':
      return l10n.featureJumpDownDesc;
    case 'search_in_thread':
      return l10n.featureSearchInThreadDesc;
    default:
      return f.description;
  }
}
