import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/config/constants.dart';
import 'package:hacki/config/locator.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/screens/item/models/models.dart';
import 'package:hacki/screens/screens.dart';
import 'package:hacki/screens/widgets/widgets.dart';
import 'package:hacki/services/services.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';

class MorePopupMenu extends StatelessWidget {
  const MorePopupMenu({
    required this.item,
    required this.isBlocked,
    required this.onLoginTapped,
    this.onSearchInThreadTapped,
    super.key,
  });

  final Item item;
  final bool isBlocked;
  final VoidCallback onLoginTapped;
  final VoidCallback? onSearchInThreadTapped;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VoteCubit>(
      create: (BuildContext context) =>
          VoteCubit(item: item, authBloc: context.read<AuthBloc>()),
      child: BlocConsumer<VoteCubit, VoteState>(
        listenWhen: (VoteState previous, VoteState current) {
          return previous.status != current.status;
        },
        listener: (BuildContext context, VoteState voteState) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          if (voteState.status == VoteStatus.submitted) {
            context.showSnackBar(content: l10n.snackVoteSubmitted);
          } else if (voteState.status == VoteStatus.canceled) {
            context.showSnackBar(content: l10n.snackVoteCanceled);
          } else if (voteState.status == VoteStatus.failure) {
            context.showErrorSnackBar();
          } else if (voteState.status ==
              VoteStatus.failureKarmaBelowThreshold) {
            context.showSnackBar(content: l10n.snackKarmalyBroke);
          } else if (voteState.status == VoteStatus.failureNotLoggedIn) {
            context.showSnackBar(
              content: l10n.snackNotLoggedInNoVoting,
              persist: false,
              action: onLoginTapped,
              label: l10n.itemLogIn,
            );
          } else if (voteState.status == VoteStatus.failureBeHumble) {
            context.showSnackBar(
              content: l10n.snackNoVotingOwnPost,
            );
          }

          context.pop(MenuAction.upvote);
        },
        builder: (BuildContext context, VoteState voteState) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          final bool upvoted = voteState.vote == Vote.up;
          final bool downvoted = voteState.vote == Vote.down;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlocProvider<UserCubit>(
                create: (BuildContext context) =>
                    UserCubit()..init(userId: item.by),
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (BuildContext context, UserState state) {
                    return Semantics(
                      excludeSemantics: state.status == Status.inProgress,
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedCrossFade(
                              alignment: Alignment.center,
                              duration: AppDurations.ms300,
                              crossFadeState: state.status.isLoading
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: const Icon(
                                Icons.account_circle_outlined,
                              ),
                              secondChild: const Icon(Icons.account_circle),
                            ),
                          ],
                        ),
                        title: Text(item.by),
                        subtitle: Text(state.user.description),
                        onTap: () {
                          context.pop();
                          final double fontSize = context
                              .read<PreferenceCubit>()
                              .state
                              .fontSize
                              .fontSize;
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              semanticLabel: l10n.itemAboutUserSemantics(
                                state.user.id,
                                state.user.about,
                              ),
                              title: Text(l10n.itemAboutUser(state.user.id)),
                              content: state.user.about.isEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          l10n.itemEmpty,
                                          style: const TextStyle(
                                            color: Palette.grey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SelectableLinkify(
                                      text: HtmlUtils.parseHtml(
                                        state.user.about,
                                      ),
                                      style: TextStyle(fontSize: fontSize),
                                      linkStyle: TextStyle(
                                        fontSize: fontSize,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      onOpen: (LinkableElement link) =>
                                          LinkUtils.launch(link.url, context),
                                      semanticsLabel: state.user.about,
                                    ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    locator
                                        .get<AppReviewService>()
                                        .requestReview();
                                    context.pop();
                                    onSearchUserTapped(context);
                                  },
                                  child: Text(l10n.itemSearch),
                                ),
                                TextButton(
                                  onPressed: () {
                                    locator
                                        .get<AppReviewService>()
                                        .requestReview();
                                    context.pop();
                                  },
                                  child: Text(l10n.itemOkay),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.itemSearchOnHn),
                onTap: () {
                  context.pop();
                  onSearchUserTapped(context);
                },
              ),
              if (onSearchInThreadTapped != null)
                ListTile(
                  leading: const Icon(Icons.manage_search),
                  title: Text(l10n.itemSearchInThread),
                  onTap: onSearchInThreadTapped,
                ),
              ListTile(
                leading: Icon(
                  upvoted
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_off_alt_outlined,
                  color: upvoted ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(
                  upvoted ? l10n.itemUpvoted : l10n.itemUpvote,
                  style: upvoted
                      ? TextStyle(color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                subtitle: item is Story ? Text(item.score.toString()) : null,
                onTap: context.read<VoteCubit>().upvote,
              ),
              ListTile(
                leading: Icon(
                  downvoted
                      ? Icons.thumb_down_rounded
                      : Icons.thumb_down_off_alt_outlined,
                  color: downvoted
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  downvoted ? l10n.itemDownvoted : l10n.itemDownvote,
                  style: downvoted
                      ? TextStyle(color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                onTap: context.read<VoteCubit>().downvote,
              ),
              BlocBuilder<FavCubit, FavState>(
                builder: (BuildContext context, FavState state) {
                  final bool isFav = state.favIds.contains(item.id);
                  return ListTile(
                    leading: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(
                      isFav ? l10n.itemUnfavorite : l10n.itemFavorite,
                    ),
                    onTap: () => context.pop(MenuAction.fav),
                  );
                },
              ),
              ListTile(
                leading: const Icon(FeatherIcons.share),
                title: Text(l10n.itemShare),
                onTap: () => context.pop(MenuAction.share),
              ),
              ListTile(
                leading: const Icon(Icons.local_police),
                title: Text(l10n.itemFlag),
                onTap: () => context.pop(MenuAction.flag),
              ),
              ListTile(
                leading: Icon(
                  isBlocked ? Icons.visibility : Icons.visibility_off,
                ),
                title: Text(isBlocked ? l10n.itemUnblock : l10n.itemBlock),
                onTap: () => context.pop(MenuAction.block),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: Text(l10n.itemViewInBrowser),
                onTap: () {
                  context.pop();
                  final String url =
                      '${Constants.hackerNewsItemLinkPrefix}${item.id}';
                  LinkUtils.launch(
                    url,
                    context,
                    shouldUseHackiForHnLink: false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.itemCancel),
                onTap: () => context.pop(MenuAction.cancel),
              ),
            ],
          );
        },
      ),
    );
  }

  void onSearchUserTapped(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return BlocProvider<SearchCubit>(
          create: (_) =>
              SearchCubit()..addFilter(PostedByFilter(author: item.by)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - Dimens.pt120,
            child: const Column(
              children: <Widget>[
                Expanded(child: SearchScreen(isInBottomSheet: true)),
              ],
            ),
          ),
        );
      },
    );
  }
}
