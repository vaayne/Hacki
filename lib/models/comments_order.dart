import 'package:flutter/widgets.dart';
import 'package:hacki/l10n/app_localizations.dart';

enum CommentsOrder {
  natural('Natural'),
  newestFirst('Newest first'),
  oldestFirst('Oldest first');

  const CommentsOrder(this.description);

  final String description;

  /// Localized label shown in the comments order selector.
  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      CommentsOrder.natural => l10n.commentsOrderNatural,
      CommentsOrder.newestFirst => l10n.commentsOrderNewestFirst,
      CommentsOrder.oldestFirst => l10n.commentsOrderOldestFirst,
    };
  }

  @override
  String toString() => description;
}
