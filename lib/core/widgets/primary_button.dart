import 'package:flutter/material.dart';

/// Full-width filled action button with an optional icon and busy state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isBusy;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: isDestructive
            ? FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              )
            : null,
        onPressed: isBusy ? null : onPressed,
        icon: isBusy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.check),
        label: Text(label),
      ),
    );
  }
}
