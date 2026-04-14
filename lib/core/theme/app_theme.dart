import 'package:flutter/material.dart';

class AppTheme {
  // Primary Medical Colors (Teal/Blue)
  static const Color primaryLight = Color(0xFF006A6A);
  static const Color secondaryLight = Color(0xFF4A6363);
  static const Color accentLight = Color(0xFF00A3A3);

  static const Color primaryDark = Color(0xFF80D4D4);
  static const Color secondaryDark = Color(0xFFB1CCCC);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      primary: primaryLight,
      secondary: secondaryLight,
      surface: const Color(0xFFF4F9F9),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      surface: const Color(0xFF191C1C),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF191C1C),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2E3131),
    ),
  );
}
