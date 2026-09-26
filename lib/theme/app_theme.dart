import 'package:flutter/material.dart';

class AppTheme {
  // Primary Palette
  static const Color primaryNavy = Color(0xFF071A33);
  static const Color cardColor = Color(0xFF0C2445);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color lightBlueAccent = Color(0xFF1E3A5F);

  // Status & Feedback Colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color dangerRed = Color(0xFFFF3D00);

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E9BAE);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryNavy,
      primaryColor: accentOrange,
      colorScheme: const ColorScheme.dark(
        primary: accentOrange,
        surface: cardColor,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        elevation: 0,
      ),
    );
  }
}
