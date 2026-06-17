import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';

/// App bar toggle that turns inline translation on or off for the whole
/// thread. Hidden unless the translation feature is enabled in settings.
class TranslationToggleButton extends StatelessWidget {
  const TranslationToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool enabled = context.select<PreferenceCubit, bool>(
      (PreferenceCubit cubit) => cubit.state.isTranslationEnabled,
    );
    if (!enabled) return const SizedBox.shrink();

    return BlocBuilder<TranslationCubit, TranslationState>(
      buildWhen: (TranslationState p, TranslationState c) =>
          p.active != c.active,
      builder: (BuildContext context, TranslationState state) {
        return IconButton(
          icon: Icon(
            Icons.translate,
            size: TextDimens.pt20,
            color: state.active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            HapticFeedbackUtils.light();
            context.read<TranslationCubit>().toggle();
          },
        );
      },
    );
  }
}
