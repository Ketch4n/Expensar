import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized app colors to avoid magic color values scattered across files.
abstract final class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primaryLighter = Color(0xFF8BC34A);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF7C4DFF);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
}

/// Centralized text styles.
abstract final class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}

/// Shared decoration helpers.
abstract final class AppDecorations {
  static BoxDecoration card({double radius = 20}) => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [cardShadow],
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000), // black 5%
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}

/// Build the app-wide ThemeData.
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    useMaterial3: true,
  );
}
