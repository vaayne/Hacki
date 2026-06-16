import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/services/services.dart';
import 'package:hacki/styles/styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.shouldShowExitButton = false});

  final bool shouldShowExitButton;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesBloc, StoriesState>(
      buildWhen: (StoriesState previous, StoriesState current) =>
          previous.isOfflineReading != current.isOfflineReading,
      builder: (BuildContext context, StoriesState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        if (state.isOfflineReading) {
          return MaterialBanner(
            dividerColor: Palette.transparent,
            content: Text(
              shouldShowExitButton
                  ? l10n.commonOfflineModeWithExit
                  : l10n.commonOfflineMode,
              textAlign: shouldShowExitButton
                  ? TextAlign.left
                  : TextAlign.center,
            ),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            actions: <Widget>[
              if (shouldShowExitButton)
                TextButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(l10n.commonExitOfflineMode),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => context.pop(false),
                              child: Text(l10n.commonCancel),
                            ),
                            TextButton(
                              onPressed: () => context.pop(true),
                              child: Text(
                                l10n.commonYes,
                                style: const TextStyle(color: Palette.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ).then((bool? value) {
                      if (context.mounted && (value ?? false)) {
                        context.read<StoriesBloc>().add(
                          StoriesExitOfflineMode(),
                        );
                        context.read<AuthBloc>().add(AuthInitialize());
                        context.read<PinCubit>().init();
                        WebAnalyzer.cacheMap.clear();
                      }
                    });
                  },
                  child: Text(l10n.commonExit),
                )
              else
                Container(),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
