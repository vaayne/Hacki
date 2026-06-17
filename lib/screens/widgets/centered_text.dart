import 'package:flutter/material.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/styles/styles.dart';

/// Distinguishes the placeholder variants whose label is localized at build
/// time; `null` means a caller-supplied [CenteredText.text] is used verbatim.
enum _CenteredTextKind { hidden, deleted, dead, blocked, empty }

class CenteredText extends StatelessWidget {
  const CenteredText({
    required this.text,
    super.key,
    this.color = Palette.grey,
  }) : _kind = null;

  const CenteredText._kind({required _CenteredTextKind kind, super.key})
    : text = '',
      color = Palette.grey,
      _kind = kind;

  const CenteredText.hidden({Key? key})
    : this._kind(key: key, kind: _CenteredTextKind.hidden);

  const CenteredText.deleted({Key? key})
    : this._kind(key: key, kind: _CenteredTextKind.deleted);

  const CenteredText.dead({Key? key})
    : this._kind(key: key, kind: _CenteredTextKind.dead);

  const CenteredText.blocked({Key? key})
    : this._kind(key: key, kind: _CenteredTextKind.blocked);

  const CenteredText.empty({Key? key})
    : this._kind(key: key, kind: _CenteredTextKind.empty);

  final String text;
  final Color color;
  final _CenteredTextKind? _kind;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = switch (_kind) {
      _CenteredTextKind.hidden => l10n.centeredHidden,
      _CenteredTextKind.deleted => l10n.centeredDeleted,
      _CenteredTextKind.dead => l10n.centeredDead,
      _CenteredTextKind.blocked => l10n.centeredBlocked,
      _CenteredTextKind.empty => l10n.centeredEmpty,
      null => text,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Dimens.pt12),
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}
