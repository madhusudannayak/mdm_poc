import 'package:flutter/material.dart';

import '../../domain/entities/application_schedule.dart';
import 'exact_alarm_notice.dart';
import 'schedule_list_item.dart';

class TimeRestrictionContent extends StatelessWidget {
  const TimeRestrictionContent({
    required this.overview,
    required this.isBusy,
    super.key,
  });

  final ScheduleOverview overview;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final schedules = overview.schedules;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (isBusy) const LinearProgressIndicator(),
        if (!overview.canScheduleExactAlarms) ...[
          const ExactAlarmNotice(),
          const SizedBox(height: 12),
        ],
        if (schedules.isEmpty) const TimeRestrictionEmptyView(),
        for (final schedule in schedules) ...[
          ScheduleListItem(
            key: ValueKey(schedule.id),
            schedule: schedule,
            isBusy: isBusy,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class TimeRestrictionEmptyView extends StatelessWidget {
  const TimeRestrictionEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('No time restrictions yet.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            'Add one to allow an application only during chosen hours.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
