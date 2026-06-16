import 'package:flutter/material.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/screens/widgets/widgets.dart';

typedef DateRangeCallback = void Function(DateTime, DateTime);

enum CustomDateTimeRange {
  pastDay(Duration(days: 1), label: 'past day'),
  pastWeek(Duration(days: 7), label: 'past week'),
  pastMonth(Duration(days: 31), label: 'past month'),
  pastYear(Duration(days: 365), label: 'past year');

  const CustomDateTimeRange(this.duration, {required this.label});

  final Duration duration;
  final String label;

  String localizedLabel(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (this) {
      CustomDateTimeRange.pastDay => l10n.rangePastDay,
      CustomDateTimeRange.pastWeek => l10n.rangePastWeek,
      CustomDateTimeRange.pastMonth => l10n.rangePastMonth,
      CustomDateTimeRange.pastYear => l10n.rangePastYear,
    };
  }
}

class CustomRangeFilterChip extends StatelessWidget {
  const CustomRangeFilterChip({
    required this.range,
    required this.onTap,
    super.key,
  });

  final CustomDateTimeRange range;
  final DateRangeCallback onTap;

  static Widget pastDay({required DateRangeCallback onTap}) {
    return CustomRangeFilterChip(
      range: CustomDateTimeRange.pastDay,
      onTap: onTap,
    );
  }

  static Widget pastWeek({required DateRangeCallback onTap}) {
    return CustomRangeFilterChip(
      range: CustomDateTimeRange.pastWeek,
      onTap: onTap,
    );
  }

  static Widget pastMonth({required DateRangeCallback onTap}) {
    return CustomRangeFilterChip(
      range: CustomDateTimeRange.pastMonth,
      onTap: onTap,
    );
  }

  static Widget pastYear({required DateRangeCallback onTap}) {
    return CustomRangeFilterChip(
      range: CustomDateTimeRange.pastYear,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomChip(
      onSelected: (bool value) {
        final DateTime now = DateTime.now();
        onTap(now.subtract(range.duration), now);
      },
      selected: false,
      label: range.localizedLabel(context),
    );
  }
}
