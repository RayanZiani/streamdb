import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    cardColor: AppColors.dark.cardBackground,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    cardColor: AppColors.light.cardBackground,
  );
}

class AppColors {
  static const _ColorScheme dark = _ColorScheme(
    background: Color(0xFF121212),
    cardBackground: Color(0xFF1E1E1E),
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFF7B1FA2),
    accent: Color(0xFFE1BEE7),
    text: Colors.white,
    textSecondary: Color(0xFFB3B3B3),
    headerGradientStart: Color(0xFF4A148C),
    headerGradientMiddle: Color(0xFF6A1B9A),
    headerGradientEnd: Color(0xFF121212),
  );

  static const _ColorScheme light = _ColorScheme(
    background: Colors.white,
    cardBackground: Color(0xFFF5F5F5),
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFFBA68C8),
    accent: Color(0xFF4A148C),
    text: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    headerGradientStart: Color(0xFFCE93D8),
    headerGradientMiddle: Color(0xFFBA68C8),
    headerGradientEnd: Color(0xFFF5F5F5),
  );
}

class _ColorScheme {
  final Color background;
  final Color cardBackground;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color textSecondary;
  final Color headerGradientStart;
  final Color headerGradientMiddle;
  final Color headerGradientEnd;

  const _ColorScheme({
    required this.background,
    required this.cardBackground,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.textSecondary,
    required this.headerGradientStart,
    required this.headerGradientMiddle,
    required this.headerGradientEnd,
  });
}