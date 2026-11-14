import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Application icon from native PNG bytes, with a generic fallback.
class ApplicationIcon extends StatelessWidget {
  const ApplicationIcon({required this.iconPng, this.size = 40, super.key});

  final Uint8List? iconPng;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconPng = this.iconPng;
    final fallback = Icon(
      Icons.android,
      size: size,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    if (iconPng == null) return fallback;
    return Image.memory(
      iconPng,
      width: size,
      height: size,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
