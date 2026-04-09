import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';

class AppTheme {
  // Brand Core
  static const Color primaryColor = Color(0xFFD4AF37); // Champagne Gold

  // Dynamic Colors depending on ThemeService state
  static Color get backgroundColor => ThemeService().isDarkMode ? const Color(0xFF050505) : const Color(0xFFF5F5F7);
  static Color get surfaceColor => ThemeService().isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  static Color get textColor => ThemeService().isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  static Color get secondaryTextColor => ThemeService().isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B);

  static ThemeData get themeData => ThemeService().isDarkMode ? darkTheme : lightTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor, size: 20),
        titleTextStyle: GoogleFonts.outfit(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.w200, letterSpacing: -1),
        headlineMedium: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.w300, letterSpacing: 1),
        titleLarge: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.w400, letterSpacing: 1.5),
        titleMedium: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w400),
        bodyLarge: GoogleFonts.inter(color: secondaryTextColor, height: 1.5),
        bodyMedium: GoogleFonts.inter(color: secondaryTextColor),
        labelLarge: GoogleFonts.outfit(color: backgroundColor, fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Sharp, architectural edges
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.transparent), // Border handled dynamically in UI
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
        labelStyle: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w300),
        hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
        prefixIconColor: primaryColor,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Light Background
      cardColor: const Color(0xFFFFFFFF), // Light Surface
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Color(0xFFFFFFFF),
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A), size: 20),
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w200, letterSpacing: -1),
        headlineMedium: GoogleFonts.outfit(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w300, letterSpacing: 1),
        titleLarge: GoogleFonts.outfit(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w400, letterSpacing: 1.5),
        titleMedium: GoogleFonts.inter(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w400),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF6B6B6B), height: 1.5),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF6B6B6B)),
        labelLarge: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF050505),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B6B6B), fontWeight: FontWeight.w300),
        hintStyle: TextStyle(color: const Color(0xFF6B6B6B).withValues(alpha: 0.5)),
        prefixIconColor: primaryColor,
      ),
    );
  }
}






