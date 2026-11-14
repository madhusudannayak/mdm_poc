import 'package:flutter/material.dart';

import '../../domain/entities/application_schedule.dart';

/// Display helpers for schedules.
abstract final class ScheduleFormatting {
  static const List<String> dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static TimeOfDay timeOfDay(int minuteOfDay) =>
      TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);

  static String time(BuildContext context, int minuteOfDay) =>
      timeOfDay(minuteOfDay).format(context);

  /// "9:00 AM - 6:00 PM", with "(next day)" for overnight windows.
  static String window(BuildContext context, int start, int end) {
    final suffix = end <= start ? ' (next day)' : '';
    return '${time(context, start)} - ${time(context, end)}$suffix';
  }

  /// "Mon-Fri", "Every day" or "Mon, Wed, Sat".
  static String days(Iterable<int> daysOfWeek) {
    final sorted = daysOfWeek.toSet().toList()..sort();
    if (sorted.length == 7) return 'Every day';
    final isRun =
        sorted.length > 2 && sorted.last - sorted.first == sorted.length - 1;
    if (isRun) {
      return '${dayLabels[sorted.first - 1]}-${dayLabels[sorted.last - 1]}';
    }
    return sorted.map((day) => dayLabels[day - 1]).join(', ');
  }

  static String dateTime(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatMediumDate(value)}, '
        '${TimeOfDay.fromDateTime(value).format(context)}';
  }

  /// One-line description of what the device is doing for [schedule] now.
  static String currentStatus(ApplicationSchedule schedule) {
    if (!schedule.isInstalled) return 'Application not installed';
    if (!schedule.enabled) return 'Schedule disabled';
    if (schedule.isNotEnforced) return 'Restricted now, but not suspended';
    if (schedule.isWithinAllowedWindow ?? false) {
      return (schedule.isApplicationSuspended ?? false)
          ? 'Inside allowed time, suspended by the blocklist'
          : 'Allowed now';
    }
    return 'Restricted now (suspended)';
  }
}
