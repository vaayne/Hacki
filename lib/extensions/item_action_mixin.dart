import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hacki/blocs/auth/auth_bloc.dart';
import 'package:hacki/config/constants.dart';
import 'package:hacki/config/paths.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/screens/item/models/models.dart';
import 'package:hacki/screens/item/widgets/widgets.dart';
import 'package:hacki/screens/screens.dart'
    show ItemScreenArgs, ShareScreenArgs;
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

@optionalTypeArgs
mixin ItemActionMixin<T extends StatefulWidget> on State<T> {
  void showSnackBar({
    required String content,
    VoidCallback? action,
    String? label,
    bool? persist,
  }) {
    context.showSnackBar(
      content: content,
      action: action,
      label: label,
      persist: persist,
    );
  }

  void showErrorSnackBar([String? message]) =>
      context.showErrorSnackBar(message);

  Future<void>? goToItemScreen({
    required ItemScreenArgs args,
    bool forceNewScreen = false,
  }) {
    final bool splitViewEnabled = context.read<SplitViewCubit>().state.enabled;

    if (splitViewEnabled && !forceNewScreen) {
      context.read<SplitViewCubit>().updateItemScreenArgs(args);
    } else {
      context.push(Paths.item.landing, extra: args);
    }

    return Future<void>.value();
  }

  void onMoreTapped(
    Item item,
    Rect? rect, {
    Item? parent,
    VoidCallback? onSearchInThreadTapped,
  }) {
    HapticFeedbackUtils.light();

    if (item.dead || item.deleted) {
      return;
    }

    final bool isBlocked = context
        .read<BlocklistCubit>()
        .state
        .blocklist
        .contains(item.by);
    showModalBottomSheet<MenuAction>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: MorePopupMenu(
            item: item,
            isBlocked: isBlocked,
            onLoginTapped: onLoginTapped,
            onSearchInThreadTapped: onSearchInThreadTapped,
          ),
        );
      },
    ).then((MenuAction? action) {
      if (action != null) {
        switch (action) {
          case MenuAction.upvote:
            break;
          case MenuAction.downvote:
            break;
          case MenuAction.fav:
            onFavTapped(item);
          case MenuAction.share:
            onShareTapped(item, rect, parent: parent);
          case MenuAction.flag:
            onFlagTapped(item);
          case MenuAction.block:
            onBlockTapped(item, isBlocked: isBlocked);
          case MenuAction.cancel:
            break;
        }
      }
    });
  }

  void onFavTapped(Item item) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FavCubit favCubit = context.read<FavCubit>();
    final bool isFav = favCubit.state.favIds.contains(item.id);
    if (isFav) {
      favCubit.removeFav(item.id);
      showSnackBar(content: l10n.actionRemovedFromFavorites);
      HapticFeedbackUtils.success();
    } else {
      favCubit.addFav(item.id);
      showSnackBar(content: l10n.actionAddedToFavorites);
      HapticFeedbackUtils.success();
    }
  }

  Future<void> onShareTapped(Item item, Rect? rect, {Item? parent}) async {
    late final String? linkToShare;
    linkToShare = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                onTap: () => context.pop('image'),
                title: Text(l10n.actionShareAsImage),
              ),
              if (item.url.isNotEmpty)
                ListTile(
                  onTap: () => context.pop(item.url),
                  title: Text(l10n.actionLinkToArticle),
                ),
              ListTile(
                onTap: () => context.pop(
                  '${Constants.hackerNewsItemLinkPrefix}${item.id}',
                ),
                title: Text(l10n.actionLinkToHn),
              ),
            ],
          ),
        );
      },
    );

    if (linkToShare == 'image' && mounted) {
      await context.push(
        Paths.share.landing,
        extra: ShareScreenArgs(item: item, parent: parent),
      );
    } else if (linkToShare != null) {
      await SharePlus.instance.share(
        ShareParams(uri: Uri.parse(linkToShare), sharePositionOrigin: rect),
      );
    }
  }

  void onFlagTapped(Item item) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.actionFlagThisComment),
          content: Text(
            l10n.actionFlagThisCommentBy(item.by),
            style: const TextStyle(color: Palette.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(l10n.actionYes),
            ),
          ],
        );
      },
    ).then((bool? yesTapped) {
      if (mounted && (yesTapped ?? false)) {
        context.read<AuthBloc>().add(AuthFlag(item: item));
        showSnackBar(content: l10n.actionCommentFlagged);
        HapticFeedbackUtils.success();
      }
    });
  }

  void onBlockTapped(Item item, {required bool isBlocked}) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isBlocked ? l10n.actionUnblockThisUser : l10n.actionBlockThisUser,
          ),
          content: Text(
            isBlocked
                ? l10n.actionUnblockUserConfirm(item.by)
                : l10n.actionBlockUserConfirm(item.by),
            style: const TextStyle(color: Palette.grey),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(l10n.actionYes),
            ),
          ],
        );
      },
    ).then((bool? yesTapped) {
      if (!mounted) return;

      if (yesTapped ?? false) {
        if (isBlocked) {
          context.read<BlocklistCubit>().removeFromBlocklist(item.by);
        } else {
          context.read<BlocklistCubit>().addToBlocklist(item.by);
        }

        showSnackBar(
          content: isBlocked
              ? l10n.actionUserUnblocked
              : l10n.actionUserBlocked,
        );
        HapticFeedbackUtils.success();
      }
    });
  }

  void onLoginTapped() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoginDialog();
      },
    );
  }
}
