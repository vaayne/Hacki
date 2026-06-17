import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/screens/widgets/widgets.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';

class ItemText extends StatelessWidget {
  const ItemText({
    required this.item,
    required this.textScaler,
    required this.selectable,
    super.key,
    this.onTap,
  });

  final Item item;
  final TextScaler textScaler;
  final bool selectable;

  /// Reserved for collapsing a comment tile when
  /// [CollapseModePreference] is enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PreferenceState prefState = context.read<PreferenceCubit>().state;
    final TextStyle style = TextStyle(fontSize: prefState.fontSize.fontSize);
    final TextStyle linkStyle = TextStyle(
      fontSize: prefState.fontSize.fontSize,
      decoration: TextDecoration.underline,
      color: Theme.of(context).colorScheme.primary,
    );

    void onSelectionChanged(
      TextSelection selection,
      SelectionChangedCause? cause,
    ) {
      if (cause == SelectionChangedCause.longPress &&
          selection.baseOffset != selection.extentOffset &&
          item is Comment) {
        context.tryRead<CommentsCubit>()?.lock(item as Comment);
      }
    }

    final Widget original;
    if (selectable && item is Buildable) {
      original = SelectableText.rich(
        buildTextSpan(
          (item as Buildable).elements,
          primaryColor: Theme.of(context).colorScheme.primaryContainer,
          style: style,
          linkStyle: linkStyle,
          onOpen: (LinkableElement link) => LinkUtils.launch(link.url, context),
        ),
        scrollPhysics: const NeverScrollableScrollPhysics(),
        selectionColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withAlpha(180),
        onTap: onTap,
        textScaler: textScaler,
        onSelectionChanged: onSelectionChanged,
        contextMenuBuilder:
            (BuildContext context, EditableTextState editableTextState) =>
                contextMenuBuilder(context, editableTextState, item: item),
        semanticsLabel: item.text,
      );
    } else if (item is Buildable) {
      original = InkWell(
        child: Text.rich(
          buildTextSpan(
            (item as Buildable).elements,
            primaryColor: Theme.of(context).colorScheme.primaryContainer,
            style: style,
            linkStyle: linkStyle,
            onOpen: (LinkableElement link) =>
                LinkUtils.launch(link.url, context),
          ),
          textScaler: textScaler,
          semanticsLabel: item.text,
        ),
      );
    } else if (selectable) {
      original = InkWell(
        child: SelectableLinkify(
          text: item.text,
          textScaler: textScaler,
          style: style,
          linkStyle: linkStyle,
          onOpen: (LinkableElement link) =>
              LinkUtils.launch(link.url, context),
          contextMenuBuilder:
              (BuildContext context, EditableTextState editableTextState) =>
                  contextMenuBuilder(context, editableTextState, item: item),
        ),
      );
    } else {
      original = InkWell(
        child: Linkify(
          text: item.text,
          textScaler: textScaler,
          style: style,
          linkStyle: linkStyle,
          onOpen: (LinkableElement link) =>
              LinkUtils.launch(link.url, context),
        ),
      );
    }

    if (!prefState.isTranslationEnabled || item.text.isEmpty) {
      return original;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        original,
        _TranslationSection(
          item: item,
          style: style,
          linkStyle: linkStyle,
          textScaler: textScaler,
          targetLanguage: _targetLanguage(context),
        ),
      ],
    );
  }

  /// Language the comment/story is translated into, derived from the active
  /// app locale.
  static String _targetLanguage(BuildContext context) =>
      switch (Localizations.localeOf(context).languageCode) {
        'zh' => 'Simplified Chinese',
        _ => 'English',
      };
}

/// The "Translate" affordance and the translated text rendered beneath the
/// original. Listens only to its own item's translation so sibling comments
/// don't rebuild.
class _TranslationSection extends StatelessWidget {
  const _TranslationSection({
    required this.item,
    required this.style,
    required this.linkStyle,
    required this.textScaler,
    required this.targetLanguage,
  });

  final Item item;
  final TextStyle style;
  final TextStyle linkStyle;
  final TextScaler textScaler;
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TranslationCubit cubit = context.read<TranslationCubit>();

    void translate() => cubit.translate(
      id: item.id,
      text: item.text,
      targetLanguage: targetLanguage,
    );

    return BlocBuilder<TranslationCubit, TranslationState>(
      buildWhen: (TranslationState p, TranslationState c) =>
          p.active != c.active || p.of(item.id) != c.of(item.id),
      builder: (BuildContext context, TranslationState state) {
        if (!state.active) return const SizedBox.shrink();

        final ItemTranslation translation = state.of(item.id);
        switch (translation.status) {
          case TranslationStatus.idle:
            // Translate as the item scrolls into view while the toggle is on.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final TranslationState s = cubit.state;
              if (s.active && s.of(item.id).status == TranslationStatus.idle) {
                translate();
              }
            });
            return _progress(context, l10n);
          case TranslationStatus.inProgress:
            return _progress(context, l10n);
          case TranslationStatus.success:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Divider(height: Dimens.pt16),
                Linkify(
                  text: translation.text ?? '',
                  textScaler: textScaler,
                  style: style,
                  linkStyle: linkStyle,
                  onOpen: (LinkableElement link) =>
                      LinkUtils.launch(link.url, context),
                ),
              ],
            );
          case TranslationStatus.missingApiKey:
            return _TranslationButton(
              icon: Icons.key_off,
              label: l10n.translationApiKeyMissing,
              onPressed: translate,
            );
          case TranslationStatus.failure:
            return _TranslationButton(
              icon: Icons.refresh,
              label: l10n.translationRetry,
              onPressed: translate,
            );
        }
      },
    );
  }

  Widget _progress(BuildContext context, AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.pt8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: Dimens.pt12,
              height: Dimens.pt12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBoxes.pt8,
            Text(l10n.translationTranslating, style: style),
          ],
        ),
      ),
    );
  }
}

class _TranslationButton extends StatelessWidget {
  const _TranslationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: Dimens.pt16),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.pt8),
          visualDensity: VisualDensity.compact,
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
