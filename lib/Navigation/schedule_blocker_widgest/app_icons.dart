
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({required this.icon});

  final Uint8List? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return const Icon(Icons.android, size: 35);
    }

    return Image.memory(
      icon!,
      width: 40,
      height: 40,
      cacheWidth: 80,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) {
        return const Icon(Icons.android, size: 35);
      },
    );
  }
}