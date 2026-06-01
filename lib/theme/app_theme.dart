import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized app colors — static brand colors that don't change with theme.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF43A047);
  static const Color primaryLighter = Color(0xFF66BB6A);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF7C4DFF);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);

  // Legacy — prefer Theme.of(context) colors for theme-aware usage.
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
}

/// Extension on [BuildContext] for quick access to theme-aware colors.
extension ThemeColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBackground =>
      isDark ? AppColors.darkBackground : AppColors.background;
  Color get cardColor =>
      isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get subtitleColor => isDark ? Colors.grey[400]! : Colors.grey[500]!;
  Color get chipBackground => isDark ? Colors.grey[800]! : Colors.grey[100]!;
  Color get dividerColor => isDark ? Colors.grey[800]! : Colors.grey[100]!;
}

/// Centralized text styles.
/// For theme-aware text colors, use `context.textPrimary` or `Theme.of(context)`.
abstract final class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
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
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}

/// Shared decoration helpers — theme-aware when [BuildContext] is provided.
abstract final class AppDecorations {
  /// Returns a card decoration. Pass [context] for theme-aware colors.
  /// Falls back to light-mode colors if no context is provided.
  static BoxDecoration card([BuildContext? context, double radius = 20]) {
    final color = context != null
        ? context.cardColor
        : AppColors.cardBackground;
    final shadow = context != null ? cardShadow(context) : _lightShadow;
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [shadow],
    );
  }

  static BoxShadow cardShadow([BuildContext? context]) {
    if (context != null && context.isDark) {
      return BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      );
    }
    return _lightShadow;
  }

  static const BoxShadow _lightShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  );
}

/// Build the light ThemeData.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}

/// Build the dark ThemeData.
ThemeData buildDarkAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCardBackground,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkCardBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
    ),
    useMaterial3: true,
  );
}
