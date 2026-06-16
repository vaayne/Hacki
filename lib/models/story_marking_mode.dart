import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';

/// Used for determining when to mark a story as read.
enum StoryMarkingMode {
  // Mark a story as read after user scrolls past it.
  scrollPast('scrolling past'),
  // Mark a story as read after user taps on it.
  tap('tapping'),
  // Mark a story as read after user scrolls past or taps on it, whichever
  // happens the first.
  scrollPastOrTap('scrolling past or tapping'),
  swipeGestureOnly('swipe gesture only');

  const StoryMarkingMode(this.label);

  final String label;

  /// Localized label shown in the story marking mode selector.
  String localizedLabel(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      StoryMarkingMode.scrollPast => l10n.storyMarkingModeScrollPast,
      StoryMarkingMode.tap => l10n.storyMarkingModeTap,
      StoryMarkingMode.scrollPastOrTap => l10n.storyMarkingModeScrollPastOrTap,
      StoryMarkingMode.swipeGestureOnly =>
        l10n.storyMarkingModeSwipeGestureOnly,
    };
  }

  bool get shouldDetectScrollingPast =>
      this == StoryMarkingMode.scrollPast ||
      this == StoryMarkingMode.scrollPastOrTap;

  bool get shouldDetectTapping =>
      this == StoryMarkingMode.tap || this == StoryMarkingMode.scrollPastOrTap;
}
