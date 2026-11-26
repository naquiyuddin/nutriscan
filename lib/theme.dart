import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLOR PALETTE ---
  static const Color background = Color(0xFF0D0F14);
  static const Color surface = Color(0xFF161A23);
  static const Color surfaceHighlight = Color(0xFF1E2431);
  static const Color border = Color(0xFF252A36);

  static const Color primary = Color(0xFFA3E635); // Electric Lime
  static const Color primaryDark = Color(0xFF10B981); // Mint Green
  static const Color accentCoral = Color(0xFFF97316); // Calorie Burn

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // --- TYPOGRAPHY ---
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- MAIN THEME DATA ---
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryDark,
        surface: surface,
        onSurface: textPrimary,
        error: accentCoral,
        outline: border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: background,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textTertiary);
        }),
      ),
    );
  }
}