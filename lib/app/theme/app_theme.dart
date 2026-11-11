import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

enum AppColorProfile {
  orchid,
  emerald,
  slateDiscreet,
  highContrastWarm,
  nightShield,
}

abstract class AppTheme {
  static ThemeData getTheme({
    AppColorProfile profile = AppColorProfile.orchid,
    bool isDark = false,
  }) {
    if (profile == AppColorProfile.nightShield || isDark) {
      return _buildDarkTheme();
    }

    final colorScheme = _buildColorScheme(profile);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      canvasColor: AppColors.background,
      dividerColor: AppColors.borderSubtle,
      cardColor: AppColors.surfaceContainerLowest,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSM(color: AppColors.neutralDark),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.labelLG(color: AppColors.onPrimary),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.labelLG(color: AppColors.primaryContainer),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        labelStyle: AppTypography.bodyMD(color: AppColors.neutralMuted),
        hintStyle: AppTypography.bodyMD(color: AppColors.neutralMuted),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: AppColors.neutralMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ColorScheme _buildColorScheme(AppColorProfile profile) {
    Color primary = AppColors.primary;
    Color primaryContainer = AppColors.primaryContainer;

    switch (profile) {
      case AppColorProfile.emerald:
        primary = const Color(0xFF1B5E3C);
        primaryContainer = const Color(0xFF248A65);
        break;
      case AppColorProfile.slateDiscreet:
        primary = const Color(0xFF3E434D);
        primaryContainer = const Color(0xFF5A616E);
        break;
      case AppColorProfile.highContrastWarm:
        primary = const Color(0xFF4A1026);
        primaryContainer = const Color(0xFF701538);
        break;
      case AppColorProfile.orchid:
      default:
        primary = AppColors.primary;
        primaryContainer = AppColors.primaryContainer;
        break;
    }

    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141218),
      canvasColor: const Color(0xFF141218),
      cardColor: const Color(0xFF201D25),
      dividerColor: const Color(0xFF332D3A),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFEFB0FF),
        onPrimary: Color(0xFF4C1061),
        primaryContainer: Color(0xFF672A7C),
        onPrimaryContainer: Color(0xFFFAD7FF),
        secondary: Color(0xFFCCC2DB),
        onSecondary: Color(0xFF332D41),
        secondaryContainer: Color(0xFF4A4358),
        onSecondaryContainer: Color(0xFFE8DEF8),
        tertiary: Color(0xFFFFB1C8),
        onTertiary: Color(0xFF5E112B),
        tertiaryContainer: Color(0xFF7B2941),
        onTertiaryContainer: Color(0xFFFFD9E2),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: Color(0xFF141218),
        onSurface: Color(0xFFE6E1E5),
        surfaceContainerHighest: Color(0xFF49454F),
        onSurfaceVariant: Color(0xFFCAC4D0),
        outline: Color(0xFF938F99),
      ),
    );
  }
}
