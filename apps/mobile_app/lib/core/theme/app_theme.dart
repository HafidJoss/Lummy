import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Vibrant Kinetic Learning Colors
  static const Color surface = Color(0xFFF9F9FC);
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainer = Color(0xFFEEEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E5);

  static const Color primary = Color(0xFF001E9B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF002DD6);
  static const Color onPrimaryContainer = Color(0xFFAAB4FF);

  static const Color secondary = Color(0xFF346B00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF90FD3B);
  static const Color onSecondaryContainer = Color(0xFF377200);

  static const Color tertiary = Color(0xFF671200);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF8F1D00);
  static const Color onTertiaryContainer = Color(0xFFFFA089);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFF757687);
  static const Color outlineVariant = Color(0xFFC5C5D8);

  static const Color surfaceVariant = Color(0xFFE2E2E5);
  static const Color onSurface = Color(0xFF1A1C1E);

  static const Color gray500 = Color(0xFF757687);
  static const Color gray700 = Color(0xFF444656);
  static const Color gray900 = Color(0xFF1A1C1E);

  // Aliases for backwards compatibility with existing UI
  static const Color background = surface;
  static const Color success = secondary;
  static const Color warning = tertiary;
  static const Color accent = tertiary;
}

class AppSpacing {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;
}

class AppShadows {
  // Soft Tactile Shadows (Level 1 tint with primary blue)
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F002DD6), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14002DD6), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A002DD6), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.quicksand().fontFamily,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.gray900,
        primaryContainer: AppColors.primaryContainer,
        secondaryContainer: AppColors.secondaryContainer,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.quicksand(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.8),
        displayMedium: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.3),
        headlineLarge: GoogleFonts.quicksand(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900),
        headlineMedium: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900),
        titleLarge: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900),
        bodyLarge: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700),
        bodyMedium: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700),
        labelLarge: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gray500,
            letterSpacing: 0.5),
        labelSmall: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p24, vertical: AppSpacing.p24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.outlineVariant, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
