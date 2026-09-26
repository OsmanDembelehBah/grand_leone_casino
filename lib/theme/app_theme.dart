import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Palette
  static const Color primaryNavy = Color(0xFF0F1E36);
  static const Color scaffoldLightBg = Color(0xFFF4F6F9);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color lightBlueAccent = Color(0xFFE2E8F0);

  // Status & Feedback Colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color dangerRed = Color(0xFFFF3D00);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldLightBg,
      primaryColor: primaryNavy,
      colorScheme: const ColorScheme.light(
        primary: accentOrange,
        surface: cardColor,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
