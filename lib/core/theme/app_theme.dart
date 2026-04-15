import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors: Professional Blue, Slate, and Emerald
  static const Color primaryBase = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color accentEmerald = Color(0xFF00BFA6);
  static const Color warningGold = Color(0xFFFFB300);
  
  static const Color surfaceLight = Color(0xFFF8F9FD);
  static const Color surfaceDark = Color(0xFF0A0C16);
  
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF16182D);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBase,
      brightness: Brightness.light,
      primary: primaryBase,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4F7396),
      onSecondary: Colors.white,
      tertiary: accentEmerald,
      onTertiary: Colors.white,
      error: const Color(0xFFE53935),
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: const Color(0xFF1A1A1A),
      onSurfaceVariant: const Color(0xFF5A5A5A),
      outline: const Color(0xFFE0E0E0),
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      bodyLarge: GoogleFonts.outfit(color: const Color(0xFF1A1A1A)),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFF1A1A1A)),
      titleLarge: GoogleFonts.outfit(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
    ),
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
      shadowColor: primaryBase.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      color: cardLight,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBase,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primaryBase.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: primaryBase);
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5A5A5A));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryBase, size: 28);
        }
        return const IconThemeData(color: Color(0xFF5A5A5A), size: 24);
      }),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.withValues(alpha: 0.1),
      thickness: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBase,
      brightness: Brightness.dark,
      primary: primaryBase,
      onPrimary: Colors.white,
      secondary: const Color(0xFF8DA9C4),
      onSecondary: Colors.black,
      tertiary: accentEmerald,
      onTertiary: Colors.black,
      error: const Color(0xFFFF5252),
      onError: Colors.black,
      surface: surfaceDark,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFB0B0B0),
      outline: const Color(0xFF2C2C2C),
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: GoogleFonts.outfit(color: Colors.white),
      bodyMedium: GoogleFonts.outfit(color: Colors.white),
      titleLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
    ),
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
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      color: cardDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBase,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primaryBase.withValues(alpha: 0.2),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white);
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFB0B0B0));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 28);
        }
        return const IconThemeData(color: Color(0xFFB0B0B0), size: 24);
      }),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      thickness: 1,
    ),
  );
}

