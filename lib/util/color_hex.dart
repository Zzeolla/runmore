import 'package:flutter/material.dart';

extension ColorHexX on String {
  Color toColorOrDefault([Color fallback = Colors.blue]) {
    final hex = replaceAll('#', '');
    if (hex.length != 6 && hex.length != 8) return fallback;

    final buffer = StringBuffer();
    if (hex.length == 6) buffer.write('ff');
    buffer.write(hex);

    final value = int.tryParse(buffer.toString(), radix: 16);
    if (value == null) return fallback;
    return Color(value);
  }
}
