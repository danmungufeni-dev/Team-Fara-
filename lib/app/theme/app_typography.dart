import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// PadCare typography system matching padcare/DESIGN.md.
/// - Manrope: Expressive, warm headlines
/// - Inter: Hyper-legible utility across data, body, and micro-copy
abstract class AppTypography {
  // Headline XL: 32px / 40px / 800 (-0.02em)
  static TextStyle headlineXL({Color color = AppColors.neutralDark}) {
    return GoogleFonts.manrope(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.64,
      color: color,
    );
  }

  // Headline LG: 26px / 34px / 700 (-0.015em)
  static TextStyle headlineLG({Color color = AppColors.neutralDark}) {
    return GoogleFonts.manrope(
      fontSize: 26,
      height: 34 / 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.39,
      color: color,
    );
  }

  // Headline MD: 22px / 28px / 700 (-0.01em)
  static TextStyle headlineMD({Color color = AppColors.neutralDark}) {
    return GoogleFonts.manrope(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.22,
      color: color,
    );
  }

  // Headline SM: 18px / 24px / 600
  static TextStyle headlineSM({Color color = AppColors.neutralDark}) {
    return GoogleFonts.manrope(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Body LG: 16px / 24px / 400
  static TextStyle bodyLG({Color color = AppColors.onSurface}) {
    return GoogleFonts.inter(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Body MD: 14px / 20px / 400
  static TextStyle bodyMD({Color color = AppColors.onSurface}) {
    return GoogleFonts.inter(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Body SM: 13px / 18px / 400
  static TextStyle bodySM({Color color = AppColors.neutralMuted}) {
    return GoogleFonts.inter(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Label LG: 15px / 20px / 600
  static TextStyle labelLG({Color color = AppColors.neutralDark}) {
    return GoogleFonts.inter(
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Label MD: 13px / 18px / 600
  static TextStyle labelMD({Color color = AppColors.neutralDark}) {
    return GoogleFonts.inter(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Label SM: 11px / 14px / 500 (+0.04em)
  static TextStyle labelSM({Color color = AppColors.neutralMuted}) {
    return GoogleFonts.inter(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.44,
      color: color,
    );
  }
}
