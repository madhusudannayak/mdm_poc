import 'package:flutter/material.dart';

import '../../../../core/widgets/confirmation_dialog.dart';

/// A policy switch that asks for confirmation before reporting a change.
class RestrictionSwitchTile extends StatelessWidget {
  const RestrictionSwitchTile({
    required this.title,
    required this.description,
    required this.value,
    required this.enableWarning,
    required this.onConfirmed,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String description;
  final bool value;

  /// Explains the consequence of switching the restriction on.
  final String enableWarning;
  final ValueChanged<bool> onConfirmed;
  final bool enabled;

  Future<void> _change(BuildContext context, bool newValue) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: newValue ? 'Enable restriction?' : 'Remove restriction?',
      message: newValue
          ? enableWarning
          : '"$title" will no longer be enforced on this device.',
      confirmLabel: newValue ? 'ENABLE' : 'REMOVE',
      isDestructive: newValue,
    );
    if (confirmed) onConfirmed(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(description),
        isThreeLine: true,
        value: value,
        onChanged: enabled ? (newValue) => _change(context, newValue) : null,
      ),
    );
  }
}
