import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/preference.dart';

/// Localized [Preference.title] for preferences rendered in the UI.
///
/// Falls back to the English [Preference.title] for keys without a
/// translation, so adding a new preference never crashes the settings screen.
String localizedPreferenceTitle(BuildContext context, Preference<dynamic> p) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  switch (p.key) {
    case 'skipButtonsPreference':
      return l10n.prefSkipButtonsTitle;
    case 'splitViewPreference':
      return l10n.prefSplitViewTitle;
    case 'eyeCandyPreference_2.0':
      return l10n.prefEyeCandyTitle;
    case 'hackerNewsThemePreference':
      return l10n.prefHackerNewsThemeTitle;
    case 'swipeGestureMode':
      return l10n.prefSwipeGestureTitle;
    case 'notificationMode':
      return l10n.prefNotificationTitle;
    case 'collapseMode':
      return l10n.prefCollapseModeTitle;
    case 'indexedStoryTilePreference':
      return l10n.prefIndexedStoryTileTitle;
    case 'displayMode':
      return l10n.prefRichStoryTileTitle;
    case 'previewImageAlignmentPreference':
      return l10n.prefImageAlignmentTitle;
    case 'expandTileForLongerTextPreference':
      return l10n.prefExpandTileTitle;
    case 'largeStoryTileImageDisplayPreference':
      return l10n.prefShowPreviewImageTitle;
    case 'faviconMode':
      return l10n.prefShowFaviconTitle;
    case 'metadataMode':
      return l10n.prefShowMetadataTitle;
    case 'storyUrlMode':
      return l10n.prefShowUrlTitle;
    case 'dividerPreference':
      return l10n.prefDividerTitle;
    case 'readerMode':
      return l10n.prefSafariReaderTitle;
    case 'markReadStoriesMode':
      return l10n.prefMarkReadStoriesTitle;
    case 'hideStoryInsteadOfMarkingGray':
      return l10n.prefHideStoryTitle;
    case 'paginationMode':
      return l10n.prefManualPaginationTitle;
    case 'persistCollapseStateAcrossSessions':
      return l10n.prefPersistCollapseStateTitle;
    case 'preserveCollapseStateAfterScreenExit':
      return l10n.prefPreserveCollapseStateTitle;
    case 'compactCollapsedTile':
      return l10n.prefCompactCollapsedTileTitle;
    case 'highlightNewComments':
      return l10n.prefHighlightNewCommentsTitle;
    case 'customTabPreference':
      return l10n.prefCustomTabTitle;
    case 'webViewBottomSheetPreference':
      return l10n.prefWebViewBottomSheetTitle;
    case 'trueDarkMode':
      return l10n.prefTrueDarkModeTitle;
    case 'hapticFeedbackMode':
      return l10n.prefHapticFeedbackTitle;
    case 'devMode':
      return l10n.prefDevModeTitle;
    case 'storyMarkingMode':
      return l10n.prefStoryMarkingModeTitle;
    case 'appColor':
      return l10n.prefAppColorTitle;
    default:
      return p.title;
  }
}

/// Localized [Preference.subtitle]; returns an empty string for preferences
/// without a subtitle so callers can branch on [String.isNotEmpty].
String localizedPreferenceSubtitle(
  BuildContext context,
  Preference<dynamic> p,
) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  switch (p.key) {
    case 'skipButtonsPreference':
      return l10n.prefSkipButtonsSubtitle;
    case 'splitViewPreference':
      return l10n.prefSplitViewSubtitle;
    case 'eyeCandyPreference_2.0':
      return l10n.prefEyeCandySubtitle;
    case 'hackerNewsThemePreference':
      return l10n.prefHackerNewsThemeSubtitle;
    case 'swipeGestureMode':
      return l10n.prefSwipeGestureSubtitle;
    case 'notificationMode':
      return l10n.prefNotificationSubtitle;
    case 'collapseMode':
      return l10n.prefCollapseModeSubtitle;
    case 'indexedStoryTilePreference':
      return l10n.prefIndexedStoryTileSubtitle;
    case 'displayMode':
      return l10n.prefRichStoryTileSubtitle;
    case 'expandTileForLongerTextPreference':
      return l10n.prefExpandTileSubtitle;
    case 'largeStoryTileImageDisplayPreference':
      return l10n.prefShowPreviewImageSubtitle;
    case 'faviconMode':
      return l10n.prefShowFaviconSubtitle;
    case 'metadataMode':
      return l10n.prefShowMetadataSubtitle;
    case 'storyUrlMode':
      return l10n.prefShowUrlSubtitle;
    case 'dividerPreference':
      return l10n.prefDividerSubtitle;
    case 'readerMode':
      return l10n.prefSafariReaderSubtitle;
    case 'markReadStoriesMode':
      return l10n.prefMarkReadStoriesSubtitle;
    case 'hideStoryInsteadOfMarkingGray':
      return l10n.prefHideStorySubtitle;
    case 'paginationMode':
      return l10n.prefManualPaginationSubtitle;
    case 'persistCollapseStateAcrossSessions':
      return l10n.prefPersistCollapseStateSubtitle;
    case 'preserveCollapseStateAfterScreenExit':
      return l10n.prefPreserveCollapseStateSubtitle;
    case 'compactCollapsedTile':
      return l10n.prefCompactCollapsedTileSubtitle;
    case 'highlightNewComments':
      return l10n.prefHighlightNewCommentsSubtitle;
    case 'customTabPreference':
      return l10n.prefCustomTabSubtitle;
    case 'webViewBottomSheetPreference':
      return l10n.prefWebViewBottomSheetSubtitle;
    case 'trueDarkMode':
      return l10n.prefTrueDarkModeSubtitle;
    default:
      return p.subtitle;
  }
}

/// Localized label for the section [DividerPlaceholder] entries.
String localizedDividerLabel(BuildContext context, DividerPlaceholder p) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  switch (p.label) {
    case 'Thread':
      return l10n.prefDividerThread;
    case 'Look And Feel':
      return l10n.prefDividerLookAndFeel;
    default:
      return p.label;
  }
}
