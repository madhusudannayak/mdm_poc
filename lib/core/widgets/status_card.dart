import 'package:flutter/material.dart';

/// Semantic tone of a status indicator.
enum StatusTone { positive, warning, negative, neutral }

/// Dashboard-style card: icon, title, a status line and optional navigation.
class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.title,
    required this.icon,
    this.status,
    this.tone = StatusTone.neutral,
    this.description,
    this.onTap,
    super.key,
  });

  final String title;

  /// Status line with a tone dot; omit for plain navigation cards.
  final String? status;
  final IconData icon;
  final StatusTone tone;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = this.status;
    final description = this.description;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (status != null) ...[
                      const SizedBox(height: 6),
                      StatusIndicator(label: status, tone: tone),
                    ],
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coloured dot followed by a status label.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      StatusTone.positive => const Color(0xFF2E7D32),
      StatusTone.warning => const Color(0xFFB26A00),
      StatusTone.negative => theme.colorScheme.error,
      StatusTone.neutral => theme.colorScheme.outline,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
