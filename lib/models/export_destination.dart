import 'package:flutter/material.dart' show BuildContext, IconData, Icons;
import 'package:hacki/l10n/app_localizations.dart';

enum ExportDestination {
  qrCode('QR code', icon: Icons.qr_code),
  clipBoard('ClipBoard', icon: Icons.copy);

  const ExportDestination(this.label, {required this.icon});

  final String label;
  final IconData icon;

  String localizedLabel(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      ExportDestination.qrCode => l10n.exportDestinationQrCode,
      ExportDestination.clipBoard => l10n.exportDestinationClipboard,
    };
  }
}
