import 'package:flutter/material.dart';

/// FieldOps app colors. Construction-first (match fieldops-web).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0D7377);
  static const Color primaryDark = Color(0xFF0A5C5F);
  static const Color secondary = Color(0xFF5C6572);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F0);
  static const Color error = Color(0xFFC53030);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1F26);
  static const Color onSurfaceVariant = Color(0xFF5C6572);
  static const Color mutedBg = Color(0xFFE8EAE6);
  static const Color cardBorder = Color(0xFFE0E2DE);

  /// Radius tokens (logical, use with BorderRadius.circular).
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
}
