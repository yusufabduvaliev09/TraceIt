import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF090E1A);
  static const Color surface = Color(0xFF121A2B);
  static const Color surfaceAlt = Color(0xFF1A2740);
  static const Color glassStroke = Color(0x66FFFFFF);
  static const Color textMain = Color(0xFFF5F8FF);
  static const Color textSecondary = Color(0xFF9CAAC7);
  static const Color accent = Color(0xFF1EC8FF);
  static const Color accent2 = Color(0xFF6F7CFF);
  static const Color success = Color(0xFF5DFFB2);
  static const Color error = Color(0xFFFF5A7A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent2, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}