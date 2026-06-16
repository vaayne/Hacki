import 'dart:async';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/l10n/feature_l10n.dart';
import 'package:hacki/models/discoverable_feature.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';

class CustomDescribedFeatureOverlay extends StatelessWidget {
  const CustomDescribedFeatureOverlay({
    required this.feature,
    required this.child,
    required this.tapTarget,
    super.key,
    this.contentLocation = ContentLocation.trivial,
    this.onComplete,
  });

  final DiscoverableFeature feature;
  final Widget tapTarget;
  final Widget child;
  final ContentLocation contentLocation;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DescribedFeatureOverlay(
      enablePulsingAnimation: !MediaQuery.of(context).disableAnimations,
      barrierDismissible: false,
      featureId: feature.featureId,
      overflowMode: OverflowMode.extendBackground,
      targetColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      tapTarget: tapTarget,
      title: Text(
        localizedFeatureTitle(context, feature),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      description: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localizedFeatureDescription(context, feature),
            style: TextStyle(
              fontSize: TextDimens.pt16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBoxes.pt6,
          Text(
            l10n.featureTapToDismiss,
            style: TextStyle(
              fontSize: TextDimens.pt12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
      contentLocation: contentLocation,
      onBackgroundTap: () {
        HapticFeedbackUtils.light();
        FeatureDiscovery.completeCurrentStep(context);
        onComplete?.call();
        return Future<bool>.value(true);
      },
      onComplete: () async {
        HapticFeedbackUtils.light();
        onComplete?.call();
        return true;
      },
      child: child,
    );
  }
}
