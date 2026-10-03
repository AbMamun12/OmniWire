import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberpunkTheme {
  // Primary Palette
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF0D1424);
  static const Color surfaceElevated = Color(0xFF131D33);
  static const Color surfaceBorder = Color(0xFF1E2D4A);

  // Neon Accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonAmber = Color(0xFFFFB800);
  static const Color neonRed = Color(0xFFFF0055);
  static const Color neonPurple = Color(0xFFB026FF);
  static const Color neonBlue = Color(0xFF2979FF);

  // Matrix and Text
  static const Color textMain = Color(0xFFF0F4FC);
  static const Color textMuted = Color(0xFF7E8B9F);
  static const Color textDim = Color(0xFF455065);
  static const Color matrixGreen = Color(0xFF00FF66);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: neonCyan,
      cardColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonGreen,
        surface: surface,
        error: neonRed,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          color: textMain,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: neonCyan,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.jetBrainsMono(
          color: textMain,
          fontSize: 13,
        ),
        bodyMedium: GoogleFonts.jetBrainsMono(
          color: textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  static BoxDecoration glowBox({
    Color glowColor = neonCyan,
    double blurRadius = 8.0,
    double spreadRadius = 0.5,
    Color bgColor = surface,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      border: border ?? Border.all(color: glowColor.withValues(alpha: 0.4), width: 1),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.15),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ],
    );
  }
}
