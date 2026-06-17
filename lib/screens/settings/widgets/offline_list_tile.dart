import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/screens/widgets/widgets.dart';
import 'package:hacki/services/dialog_proxy.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/haptic_feedback_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OfflineListTile extends StatelessWidget {
  const OfflineListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoriesBloc, StoriesState>(
      listenWhen: (StoriesState previous, StoriesState current) =>
          previous.downloadStatus != current.downloadStatus,
      listener: (BuildContext context, StoriesState state) {
        if (state.downloadStatus == StoriesDownloadStatus.failure ||
            state.downloadStatus == StoriesDownloadStatus.finished) {
          WakelockPlus.disable();
        }
      },
      buildWhen: (StoriesState previous, StoriesState current) =>
          previous.downloadStatus != current.downloadStatus ||
          previous.storiesDownloaded != current.storiesDownloaded ||
          previous.storiesToBeDownloaded != current.storiesToBeDownloaded ||
          previous.downloadTimestamp != current.downloadTimestamp,
      builder: (BuildContext context, StoriesState state) {
        final bool downloading =
            state.downloadStatus == StoriesDownloadStatus.downloading;
        final bool downloaded =
            state.downloadStatus == StoriesDownloadStatus.finished;

        final Widget trailingWidget = () {
          if (downloading) {
            return const SizedBox(
              height: Dimens.pt24,
              width: Dimens.pt24,
              child: CustomCircularProgressIndicator(),
            );
          } else if (downloaded) {
            return Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            );
          }
          return Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.primary,
          );
        }();

        return ListTile(
          title: Text(() {
            if (downloading) {
              return AppLocalizations.of(context).settingsDownloadingStories(
                state.storiesDownloaded,
                state.storiesToBeDownloaded,
              );
            } else if (state.storiesDownloaded != 0) {
              return AppLocalizations.of(
                context,
              ).settingsStoriesDownloaded(state.storiesDownloaded);
            }
            return AppLocalizations.of(context).settingsDownloadStories;
          }()),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).settingsDownloadStoriesDescription,
              ),
              if (state.downloadStatus != StoriesDownloadStatus.downloading &&
                  state.downloadTimestamp != null)
                Text(
                  AppLocalizations.of(
                    context,
                  ).settingsLastDownloadedAt('${state.downloadDateTime}'),
                  style: TextStyle(
                    fontSize: TextDimens.pt12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(160),
                  ),
                ),
            ],
          ),
          trailing: trailingWidget,
          isThreeLine: true,
          onTap: () {
            if (state.downloadStatus == StoriesDownloadStatus.downloading) {
              DialogProxy.showAbortDownloadDialog(context);
            } else {
              context.read<StoriesBloc>().add(ClearMaxOfflineStoriesCount());
              Connectivity().checkConnectivity().then((
                List<ConnectivityResult> res,
              ) {
                if (!res.contains(ConnectivityResult.none) && context.mounted) {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBoxes.pt12,
                            Text(
                              AppLocalizations.of(
                                context,
                              ).settingsHowManyStories,
                            ),
                            for (final MaxOfflineStoriesCount count
                                in MaxOfflineStoriesCount.values)
                              ListTile(
                                title: Text(count.localizedLabel(context)),
                                onTap: () {
                                  HapticFeedbackUtils.selection();

                                  context.pop();
                                  final StoriesBloc storiesBloc =
                                      context.read<StoriesBloc>()..add(
                                        UpdateMaxOfflineStoriesCount(
                                          count: count,
                                        ),
                                      );
                                  showConfirmationDialog(context, storiesBloc);
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }
              });
            }
          },
        );
      },
    );
  }

  void showConfirmationDialog(BuildContext context, StoriesBloc storiesBloc) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).settingsDownloadWebPages),
        content: Text(
          AppLocalizations.of(context).settingsDownloadWebPagesDescription,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).settingsCancel),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context).settingsNo),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(AppLocalizations.of(context).settingsYes),
          ),
        ],
      ),
    ).then((bool? includeWebPage) {
      if (includeWebPage != null) {
        WakelockPlus.enable();

        storiesBloc.add(StoriesDownload(includingWebPage: includeWebPage));
      }
    });
  }
}
