import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../bloc/schedule_editor_bloc.dart';
import 'schedule_formatting.dart';

class ScheduleEditorForm extends StatelessWidget {
  const ScheduleEditorForm({required this.state, super.key});

  final ScheduleEditorState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage = state.errorMessage;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Application',
          children: [
            Text(state.applicationName, style: theme.textTheme.bodyLarge),
            Text(state.packageName, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Allowed time',
          children: [
            ScheduleTimeField(
              label: 'Start',
              minuteOfDay: state.startMinuteOfDay,
              onChanged: (minute) => context.read<ScheduleEditorBloc>().add(
                ScheduleStartTimeChanged(minute),
              ),
            ),
            ScheduleTimeField(
              label: 'End',
              minuteOfDay: state.endMinuteOfDay,
              onChanged: (minute) => context.read<ScheduleEditorBloc>().add(
                ScheduleEndTimeChanged(minute),
              ),
            ),
            if (state.crossesMidnight)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'This window runs overnight and ends on the following day.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Outside this time the application is suspended.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Days',
          children: [
            ScheduleDaySelector(selectedDays: state.daysOfWeek),
            const SizedBox(height: 4),
            Text(
              'The day on which the allowed time starts.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Schedule enabled'),
            subtitle: const Text('A disabled schedule does not restrict.'),
            value: state.enabled,
            onChanged: (enabled) => context.read<ScheduleEditorBloc>().add(
              ScheduleEnabledChanged(enabled: enabled),
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: state.isEditingExisting ? 'SAVE CHANGES' : 'SAVE SCHEDULE',
          icon: Icons.save_outlined,
          isBusy: state.isSubmitting,
          onPressed: () =>
              context.read<ScheduleEditorBloc>().add(const ScheduleSubmitted()),
        ),
      ],
    );
  }
}

class ScheduleTimeField extends StatelessWidget {
  const ScheduleTimeField({
    required this.label,
    required this.minuteOfDay,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int minuteOfDay;
  final ValueChanged<int> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: ScheduleFormatting.timeOfDay(minuteOfDay),
      helpText: '$label time',
    );
    if (picked != null) onChanged(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.access_time),
      title: Text(label),
      trailing: Text(
        ScheduleFormatting.time(context, minuteOfDay),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => _pick(context),
    );
  }
}

class ScheduleDaySelector extends StatelessWidget {
  const ScheduleDaySelector({required this.selectedDays, super.key});

  final Set<int> selectedDays;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        for (var day = 1; day <= 7; day++)
          FilterChip(
            label: Text(ScheduleFormatting.dayLabels[day - 1]),
            selected: selectedDays.contains(day),
            showCheckmark: false,
            onSelected: (_) =>
                context.read<ScheduleEditorBloc>().add(ScheduleDayToggled(day)),
          ),
      ],
    );
  }
}
