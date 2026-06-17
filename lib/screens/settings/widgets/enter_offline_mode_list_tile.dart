import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/utils/haptic_feedback_utils.dart';

class EnterOfflineModeListTile extends StatelessWidget {
  const EnterOfflineModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesBloc, StoriesState>(
      buildWhen: (StoriesState previous, StoriesState current) =>
          previous.isOfflineReading != current.isOfflineReading,
      builder: (BuildContext context, StoriesState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return SwitchListTile(
          value: state.isOfflineReading,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          title: Text(l10n.settingsOfflineMode),
          onChanged: (bool value) {
            HapticFeedbackUtils.light();
            context.read<StoriesBloc>().add(
              value ? StoriesEnterOfflineMode() : StoriesExitOfflineMode(),
            );
            if (value) {
              context.showSnackBar(
                content: l10n.settingsOfflineModeActivated,
              );
            } else {
              context.showSnackBar(
                content: l10n.settingsOfflineModeDeactivated,
              );
            }
          },
        );
      },
    );
  }
}
