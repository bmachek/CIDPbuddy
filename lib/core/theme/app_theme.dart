import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors: Modern Medical Teal & Slate
  static const Color primaryBase = Color(0xFF006B70);
  static const Color primaryDarken = Color(0xFF004D51);
  static const Color primaryLighten = Color(0xFF4DD8DE);
  
  static const Color surfaceLight = Color(0xFFF8FCFC);
  static const Color surfaceDark = Color(0xFF191C1C);
  
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2E3131);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBase,
      brightness: Brightness.light,
      primary: primaryBase,
      secondary: const Color(0xFF4A6363),
      surface: surfaceLight,
      onSurface: const Color(0xFF191C1C),
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: const Color(0xFF191C1C),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF191C1C),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      color: cardLight,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBase,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      indicatorColor: primaryBase.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLighten,
      brightness: Brightness.dark,
      primary: primaryLighten,
      secondary: const Color(0xFFB1CCCC),
      surface: surfaceDark,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      color: cardDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLighten,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: primaryLighten.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
