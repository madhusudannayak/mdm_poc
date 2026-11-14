import 'package:flutter/material.dart';

import '../../domain/entities/managed_application.dart';

/// Compact labels for the management state of an application.
class ApplicationStateChips extends StatelessWidget {
  const ApplicationStateChips({required this.application, super.key});

  final ManagedApplication application;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (application.isSuspended)
          StateChip(label: 'Suspended', color: colors.error),
        if (application.isBlocked && !application.isSuspended)
          StateChip(label: 'Blocked, not enforced', color: colors.error),
        if (application.isAllowed)
          const StateChip(label: 'Allowed', color: Color(0xFF2E7D32)),
        if (application.isHidden)
          StateChip(label: 'Hidden', color: colors.tertiary),
        if (!application.isEnabled)
          StateChip(label: 'Disabled', color: colors.outline),
        if (application.isSystemApplication)
          StateChip(label: 'System', color: colors.outline),
      ],
    );
  }
}

class StateChip extends StatelessWidget {
  const StateChip({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
