import 'package:flutter/material.dart';

// logica
// logica
class OmniRackColors {
  OmniRackColors._();

  static const Color background = Color(0xFFF8F8F8);
  static const Color red = Color(0xFFC81030);
  static const Color redDark = Color(0xFFA01828);
  static const Color redLight = Color(0xFFE06880);
  static const Color yellow = Color(0xFFE0B840);
  static const Color green = Color(0xFF40F000);
  static const Color text = Color(0xFF181818);
  static const Color textMuted = Color(0xFF888888);
  static const Color white = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  static Color statusColor(String status) {
    switch (status) {
      case 'alert':
        return red;
      case 'warning':
        return yellow;
      default:
        return green;
    }
  }
}
