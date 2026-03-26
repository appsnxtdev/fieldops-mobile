import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for FieldOps. Inter font, finance-mobile styles; high contrast for readability.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        color: onSurface,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.inter(
        color: onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        color: onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        color: onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        color: onSurface,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: onSurface,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: onSurface,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.inter(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
