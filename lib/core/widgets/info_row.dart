import 'package:flutter/material.dart';

/// Label/value row. A null [value] is rendered as "Unavailable" so missing
/// native data is shown honestly rather than substituted.
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.label,
    required this.value,
    this.selectable = false,
    super.key,
  });

  static const String unavailable = 'Unavailable';

  final String label;
  final String? value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: value == null ? theme.colorScheme.onSurfaceVariant : null,
      fontStyle: value == null ? FontStyle.italic : null,
    );
    final text = value ?? unavailable;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: selectable
                ? SelectableText(text, style: valueStyle)
                : Text(text, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
