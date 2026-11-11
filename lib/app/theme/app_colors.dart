import 'package:flutter/material.dart';

/// PadCare official color palette derived directly from padcare/DESIGN.md.
abstract class AppColors {
  // Brand Anchors
  static const Color primary = Color(0xFF58236A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF713B83);
  static const Color onPrimaryContainer = Color(0xFFEEAEFF);
  static const Color inversePrimary = Color(0xFFEFB0FF);

  static const Color secondary = Color(0xFF625C69);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DFEF);
  static const Color onSecondaryContainer = Color(0xFF68626F);

  static const Color tertiary = Color(0xFF701538);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF8E2E4E);
  static const Color onTertiaryContainer = Color(0xFFFFAEC1);

  // Canvas & Surfaces
  static const Color background = Color(0xFFFEF7FF);
  static const Color onBackground = Color(0xFF1E1A24);
  static const Color surface = Color(0xFFFEF7FF);
  static const Color onSurface = Color(0xFF1E1A24);
  static const Color onSurfaceVariant = Color(0xFF4D444E);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9F0FF);
  static const Color surfaceContainer = Color(0xFFF4EBF9);
  static const Color surfaceContainerHigh = Color(0xFFEEE5F3);
  static const Color surfaceContainerHighest = Color(0xFFE8DFEE);

  static const Color surfaceDim = Color(0xFFDFD7E5);
  static const Color surfaceBright = Color(0xFFFEF7FF);
  static const Color inverseSurface = Color(0xFF332F39);
  static const Color inverseOnSurface = Color(0xFFF6EEFC);

  // Outlines & Dividers
  static const Color outline = Color(0xFF7F747F);
  static const Color outlineVariant = Color(0xFFD0C2CF);
  static const Color borderSubtle = Color(0xFFE8E2EC);

  // Semantic Status Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color success = Color(0xFF248A65);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFDCF8EC);

  // Humanist & Field Outpost Warmth
  static const Color softLavender = Color(0xFFEDE4F4);
  static const Color coralPink = Color(0xFFE87596);
  static const Color neutralDark = Color(0xFF25212B);
  static const Color neutralMuted = Color(0xFF77717F);
  static const Color canvasBase = Color(0xFFFAF8FC);

  // Fixed Tokens
  static const Color primaryFixed = Color(0xFFFAD7FF);
  static const Color primaryFixedDim = Color(0xFFEFB0FF);
  static const Color onPrimaryFixed = Color(0xFF330045);
  static const Color onPrimaryFixedVariant = Color(0xFF653077);
  static const Color secondaryFixed = Color(0xFFE8DFEF);
  static const Color secondaryFixedDim = Color(0xFFCCC3D3);
  static const Color onSecondaryFixed = Color(0xFF1E1A25);
  static const Color tertiaryFixed = Color(0xFFFFD9E0);
  static const Color onTertiaryFixed = Color(0xFF3F001A);

  // Shadows
  static const Color shadowPlum = Color(0x1F713B83);
  static const Color shadowNeutral = Color(0x0A25212B);
}
