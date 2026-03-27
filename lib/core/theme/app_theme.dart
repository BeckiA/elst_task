import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary teal/aqua palette
  static const Color primary = Color(0xFF00B5D1); // Keeping bright teal for buttons
  static const Color primaryDark = Color(0xFF0091A8);
  static const Color primaryLight = Color(0xFF4DD9EC);

  // Gradient colors for header (#111729 and #14769e)
  static const Color headerGradientStart = Color(0xFF111729);
  static const Color headerGradientMid = Color(0xFF124663); // Blend
  static const Color headerGradientEnd = Color(0xFF14769E);

  // Semantic colors
  static const Color positive = Color(0xFF00C08B);
  static const Color negative = Color(0xFFFF5C5C);
  static const Color warning = Color(0xFFFFB800);

  // Neutral palette
  static const Color background = Color(0xFFF2F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textSecondary = Color(0xFF6B7A8D);
  static const Color textTertiary = Color(0xFF9BA8B7);
  static const Color divider = Color(0xFFE8ECF1);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Header text
  static const Color headerText = Color(0xFFFFFFFF);
  static const Color headerTextSecondary = Color(0xB3FFFFFF); // 70% white
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}
