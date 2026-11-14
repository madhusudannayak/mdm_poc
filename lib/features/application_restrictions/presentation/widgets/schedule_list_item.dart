import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/status_card.dart';
import '../../domain/entities/application_schedule.dart';
import '../bloc/schedule_editor_bloc.dart';
import '../bloc/time_restriction_bloc.dart';
import 'schedule_formatting.dart';

enum _ScheduleMenuAction { edit, delete }

class ScheduleListItem extends StatelessWidget {
  const ScheduleListItem({
    required this.schedule,
    required this.isBusy,
    super.key,
  });

  final ApplicationSchedule schedule;
  final bool isBusy;

  StatusTone get _tone {
    if (!schedule.isInstalled || !schedule.enabled) return StatusTone.neutral;
    if (schedule.isNotEnforced) return StatusTone.negative;
    return (schedule.isApplicationSuspended ?? false)
        ? StatusTone.warning
        : StatusTone.positive;
  }

  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<TimeRestrictionBloc>();
    await context.push<bool>(
      AppRoutes.scheduleEditor,
      extra: ScheduleEditorArgs.edit(schedule),
    );
    bloc.add(const TimeRestrictionsRequested());
  }

  Future<void> _delete(BuildContext context) async {
    final id = schedule.id;
    if (id == null) return;
    final bloc = context.read<TimeRestrictionBloc>();
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete schedule?',
      message:
          'The time restriction for ${schedule.displayName} will be removed. '
          'The application is released unless another policy still blocks it.',
      confirmLabel: 'DELETE',
      isDestructive: true,
    );
    if (confirmed) bloc.add(TimeRestrictionDeleteConfirmed(id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = schedule.id;
    final nextTransitionAt = schedule.nextTransitionAt;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(schedule.packageName, style: muted),
                  const SizedBox(height: 8),
                  Text(
                    ScheduleFormatting.window(
                      context,
                      schedule.startMinuteOfDay,
                      schedule.endMinuteOfDay,
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    ScheduleFormatting.days(schedule.daysOfWeek),
                    style: muted,
                  ),
                  const SizedBox(height: 8),
                  StatusIndicator(
                    label: ScheduleFormatting.currentStatus(schedule),
                    tone: _tone,
                  ),
                  if (schedule.enabled && nextTransitionAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Next change: '
                      '${ScheduleFormatting.dateTime(context, nextTransitionAt)}',
                      style: muted,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: schedule.enabled,
                  onChanged: isBusy || id == null
                      ? null
                      : (enabled) => context.read<TimeRestrictionBloc>().add(
                          TimeRestrictionEnabledChanged(
                            scheduleId: id,
                            enabled: enabled,
                          ),
                        ),
                ),
                PopupMenuButton<_ScheduleMenuAction>(
                  enabled: !isBusy,
                  tooltip: 'Schedule actions',
                  onSelected: (action) => switch (action) {
                    _ScheduleMenuAction.edit => _edit(context),
                    _ScheduleMenuAction.delete => _delete(context),
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _ScheduleMenuAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _ScheduleMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
