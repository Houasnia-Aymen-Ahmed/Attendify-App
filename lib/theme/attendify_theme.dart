import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendifyPalette {
  static const Color primary = Color(0xFF17385F);
  static const Color primaryStrong = Color(0xFF102846);
  static const Color secondary = Color(0xFF0D9488);
  static const Color tertiary = Color(0xFF0284C7);
  static const Color background = Color(0xFFF3F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEAF0F6);
  static const Color surfaceStrong = Color(0xFFD9E3EE);
  static const Color text = Color(0xFF13263F);
  static const Color mutedText = Color(0xFF5C6F86);
  static const Color outline = Color(0xFFD6DEE8);
  static const Color error = Color(0xFFB93815);

  // ── Statistics chart tokens ─────────────────────────────────────────────
  // Changing these updates all four chart widgets at once.
  static const Color chartGradientTop = Color(0xFFBDD8F0);
  static const Color chartGradientBottom = Color(0xFF1E5C8A);
  static const Color chartBar = secondary;
  static const Color chartBarTouched = primary;
  static const Color chartLine = tertiary;
  static const Color chartBorder = primary;
}

class AttendifyTheme {
  static ThemeData build() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AttendifyPalette.primary,
      onPrimary: Colors.white,
      secondary: AttendifyPalette.secondary,
      onSecondary: Colors.white,
      error: AttendifyPalette.error,
      onError: Colors.white,
      surface: AttendifyPalette.surface,
      onSurface: AttendifyPalette.text,
    );

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AttendifyPalette.text,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AttendifyPalette.text,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AttendifyPalette.text,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AttendifyPalette.text,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AttendifyPalette.text,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AttendifyPalette.text,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AttendifyPalette.text,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AttendifyPalette.mutedText,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AttendifyPalette.mutedText,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AttendifyPalette.mutedText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AttendifyPalette.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AttendifyPalette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AttendifyPalette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AttendifyPalette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AttendifyPalette.mutedText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AttendifyPalette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AttendifyPalette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AttendifyPalette.primary,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AttendifyPalette.surfaceMuted,
        selectedColor: AttendifyPalette.primary,
        secondarySelectedColor: AttendifyPalette.primary,
        checkmarkColor: Colors.white,
        disabledColor: AttendifyPalette.surfaceStrong,
        side: const BorderSide(color: AttendifyPalette.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AttendifyPalette.text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AttendifyPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AttendifyPalette.primary,
          side: const BorderSide(color: AttendifyPalette.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      dividerColor: AttendifyPalette.outline,
    );
  }
}
