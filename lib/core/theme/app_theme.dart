import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors: Vibrant Indigo, Soft Violet, and Emerald
  static const Color primaryBase = Color(0xFF5D5FEF);
  static const Color primaryLight = Color(0xFFC77DFF);
  static const Color accentEmerald = Color(0xFF00BFA6);
  
  static const Color surfaceLight = Color(0xFFF9FAFF);
  static const Color surfaceDark = Color(0xFF0F1021);
  
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E203B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBase,
      brightness: Brightness.light,
      primary: primaryBase,
      onPrimary: Colors.white,
      secondary: primaryLight,
      onSecondary: Colors.black,
      tertiary: accentEmerald,
      onTertiary: Colors.white,
      surface: surfaceLight,
      onSurface: const Color(0xFF1A1A1A),
      onSurfaceVariant: const Color(0xFF333333),
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: primaryBase.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.grey.withOpacity(0.05)),
      ),
      color: cardLight.withOpacity(0.9),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBase,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primaryBase.withOpacity(0.1),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: primaryBase);
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryBase, size: 28);
        }
        return IconThemeData(color: const Color(0xFF333333), size: 24);
      }),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.withOpacity(0.2),
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBase,
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Colors.black,
      secondary: primaryBase,
      onSecondary: Colors.white,
      tertiary: accentEmerald,
      onTertiary: Colors.black,
      surface: surfaceDark,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFE0E0E0),
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      color: cardDark.withOpacity(0.8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primaryLight.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: primaryLight);
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryLight, size: 28);
        }
        return const IconThemeData(color: Color(0xFFE0E0E0), size: 24);
      }),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
    ),
  );
}

