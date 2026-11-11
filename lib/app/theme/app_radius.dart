import 'package:flutter/material.dart';

/// Corner radius definitions from padcare/DESIGN.md.
abstract class AppRadius {
  static const double sm = 4.0; // 0.25rem
  static const double defaultRadius = 8.0; // 0.5rem
  static const double md = 12.0; // 0.75rem - inputs, small controls
  static const double button = 14.0; // Buttons standard
  static const double lg = 16.0; // 1.0rem - cards & containment
  static const double card = 18.0; // Base card
  static const double xl = 24.0; // 1.5rem - bottom sheets, large dialogs
  static const double full = 9999.0; // Chips, pills, circle buttons

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius buttonBorder = BorderRadius.all(Radius.circular(button));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullBorder = BorderRadius.all(Radius.circular(full));

  // Bottom Sheet Radius
  static const BorderRadius bottomSheetBorder = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
