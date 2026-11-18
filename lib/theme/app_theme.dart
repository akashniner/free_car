import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B111E);
  static const Color surface = Color(0xFF151F32);
  static const Color surfaceElevated = Color(0xFF1E2C44);
  static const Color border = Color(0xFF283955);

  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color gold = Color(0xFFF59E0B);
  static const Color electricCyan = Color(0xFF06B6D4);
  static const Color debtRed = Color(0xFFF43F5E);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmerald,
        secondary: gold,
        tertiary: electricCyan,
        surface: surface,
        error: debtRed,
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryEmerald,
        inactiveTrackColor: border,
        thumbColor: primaryEmerald,
        overlayColor: primaryEmerald.withValues(alpha: 0.2),
        valueIndicatorColor: surfaceElevated,
        valueIndicatorTextStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
