import 'package:flutter/material.dart';

/// FieldOps app colors. Mimics finance-mobile palette; construction-first usage.
class AppColors {
  AppColors._();

  // Primary brand (finance-mobile)
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A884);
  static const Color secondary = Color(0xFF7C4DFF);

  // Background dark
  static const Color bgDark = Color(0xFF0D0F14);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgCardLight = Color(0xFF1F2630);
  static const Color bgSurface = Color(0xFF252D38);

  // Background light
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgCardWhite = Color(0xFFFFFFFF);
  static const Color bgSurfaceLight = Color(0xFFEEF1F6);

  // Semantic
  static const Color expense = Color(0xFFFF5252);
  static const Color success = Color(0xFF69F0AE);
  static const Color warning = Color(0xFFFFAB40);
  static const Color info = Color(0xFF40C4FF);

  // Text (dark theme)
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8A9BB0);
  static const Color textMuted = Color(0xFF4A5568);

  // Aliases for theme/screens (light: onSurface/onSurfaceVariant)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color error = Color(0xFFFF5252);
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF1A202C);
  static const Color onSurfaceVariant = Color(0xFF4A5568);
  static const Color mutedBg = Color(0xFFEEF1F6);
  static const Color cardBorder = Color(0xFFE2E8F0);

  /// Radius tokens (use with BorderRadius.circular).
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
}
