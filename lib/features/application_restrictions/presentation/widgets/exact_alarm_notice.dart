import 'package:flutter/material.dart';

/// Shown when Android will not deliver schedule transitions at the exact
/// minute on this device.
class ExactAlarmNotice extends StatelessWidget {
  const ExactAlarmNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.schedule_outlined,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Exact alarms are not available to this app, so restrictions '
                'may start or end several minutes late. Grant "Alarms & '
                'reminders" access to this app in Android settings for exact '
                'timing. State is also re-checked periodically and whenever '
                'you press sync.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
