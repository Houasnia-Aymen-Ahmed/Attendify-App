import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color tokens ────────────────────────────────────────────────────────────
// Change any value here to update every widget that references it.

class AttendifyPalette {
  // Brand
  static const Color primary = Color(0xFF17385F);
  static const Color primaryStrong = Color(0xFF102846);
  static const Color secondary = Color(0xFF0D9488);
  static const Color tertiary = Color(0xFF0284C7);

  // Backgrounds
  static const Color background = Color(0xFFF3F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEAF0F6);
  static const Color surfaceStrong = Color(0xFFD9E3EE);

  // Text
  static const Color text = Color(0xFF13263F);
  static const Color mutedText = Color(0xFF5C6F86);

  // Borders & states
  static const Color outline = Color(0xFFD6DEE8);
  static const Color error = Color(0xFFB93815);
  static const Color success = Color(0xFF0D9488); // same as secondary

  // ── Chart tokens ───────────────────────────────────────────────────────────
  // Changing these updates all four chart widgets at once.
  static const Color chartGradientTop = Color(0xFFBDD8F0);
  static const Color chartGradientBottom = Color(0xFF1E5C8A);
  static const Color chartBar = secondary;
  static const Color chartBarTouched = primary;
  static const Color chartLine = tertiary;
  static const Color chartBorder = primary;
}

// ── Spacing tokens ───────────────────────────────────────────────────────────
// Use AttendifySpacing.md instead of a magic number like 12.

class AttendifySpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ── Border-radius tokens ────────────────────────────────────────────────────

class AttendifyRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
  static const Radius smRadius = Radius.circular(sm);
  static const Radius mdRadius = Radius.circular(md);
  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
  static const BorderRadius smAll = BorderRadius.all(smRadius);
  static const BorderRadius mdAll = BorderRadius.all(mdRadius);
  static const BorderRadius lgAll = BorderRadius.all(lgRadius);
  static const BorderRadius xlAll = BorderRadius.all(xlRadius);
}

// ── Typography helpers ───────────────────────────────────────────────────────
// Named constructors so you never inline font values in widgets.

class AttendifyTextStyle {
  static TextStyle headline1({Color? color}) => GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle headline2({Color? color}) => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle headline3({Color? color}) => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle title1({Color? color}) => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle title2({Color? color}) => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle body1({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle body2({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AttendifyPalette.text,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AttendifyPalette.mutedText,
      );

  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? AttendifyPalette.mutedText,
      );

  static TextStyle chip({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color ?? AttendifyPalette.text,
      );
}

// ── Theme ────────────────────────────────────────────────────────────────────

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
      headlineLarge: AttendifyTextStyle.headline1(),
      headlineMedium: AttendifyTextStyle.headline2(),
      headlineSmall: AttendifyTextStyle.headline3(),
      titleLarge: AttendifyTextStyle.title1(),
      titleMedium: AttendifyTextStyle.title2(),
      bodyLarge: AttendifyTextStyle.body1(),
      bodyMedium: AttendifyTextStyle.body2(),
      bodySmall: AttendifyTextStyle.caption(),
      labelLarge: AttendifyTextStyle.label(),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AttendifyPalette.mutedText,
      ),
      labelSmall: AttendifyTextStyle.labelSmall(),
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

      cardTheme: const CardThemeData(
        color: AttendifyPalette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AttendifyRadius.lgAll,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AttendifyPalette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AttendifySpacing.md + AttendifySpacing.sm, // 20
          vertical: AttendifySpacing.md + AttendifySpacing.sm,
        ),
        hintStyle: AttendifyTextStyle.body2(color: AttendifyPalette.mutedText),
        border: const OutlineInputBorder(
          borderRadius: AttendifyRadius.mdAll,
          borderSide: BorderSide(color: AttendifyPalette.outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AttendifyRadius.mdAll,
          borderSide: BorderSide(color: AttendifyPalette.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AttendifyRadius.mdAll,
          borderSide: BorderSide(
            color: AttendifyPalette.primary,
            width: 1.5,
          ),
        ),
      ),

      // ── Chips ──────────────────────────────────────────────────────────────
      // labelStyle       → unselected chip text
      // secondaryLabelStyle → selected chip text (white so it reads on primary bg)
      chipTheme: ChipThemeData(
        backgroundColor: AttendifyPalette.surfaceMuted,
        selectedColor: AttendifyPalette.primary,
        secondarySelectedColor: AttendifyPalette.primary,
        checkmarkColor: Colors.white,
        disabledColor: AttendifyPalette.surfaceStrong,
        side: const BorderSide(color: AttendifyPalette.outline),
        shape: const RoundedRectangleBorder(
          borderRadius: AttendifyRadius.mdAll,
        ),
        labelStyle: AttendifyTextStyle.chip(),
        secondaryLabelStyle: AttendifyTextStyle.chip(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AttendifyPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AttendifySpacing.md + AttendifySpacing.sm,
            vertical: AttendifySpacing.lg,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AttendifyRadius.mdAll,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AttendifySpacing.md + AttendifySpacing.sm,
            vertical: AttendifySpacing.lg,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AttendifyRadius.mdAll,
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AttendifyPalette.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      dividerColor: AttendifyPalette.outline,

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AttendifyRadius.smAll,
        ),
        backgroundColor: AttendifyPalette.text,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: AttendifySpacing.lg,
          vertical: AttendifySpacing.md,
        ),
      ),

      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: AttendifyRadius.lgAll,
        ),
        backgroundColor: AttendifyPalette.surface,
        titleTextStyle: AttendifyTextStyle.title1(),
        contentTextStyle: AttendifyTextStyle.body2(
          color: AttendifyPalette.mutedText,
        ),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AttendifyPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: AttendifyRadius.lgRadius,
            bottomRight: AttendifyRadius.lgRadius,
          ),
        ),
      ),
    );
  }
}
