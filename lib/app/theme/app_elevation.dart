import 'package:flutter/material.dart';

/// Elevation and depth system from padcare/DESIGN.md.
/// Avoids harsh drop shadows; uses subtle surface tinting and soft ambient illumination.
abstract class AppElevation {
  // Level 1: Base Card & Content Blocks
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0A713B83), // rgba(113, 59, 131, 0.04)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0525212B), // rgba(37, 33, 43, 0.02)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // Level 2: Active Touch & Floating Panels
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x14713B83), // rgba(113, 59, 131, 0.08)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0825212B), // rgba(37, 33, 43, 0.03)
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Level 3: Modals, Overlays, Bottom Drawers & Sticky Actions
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1F713B83), // rgba(113, 59, 131, 0.12)
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0A25212B), // rgba(37, 33, 43, 0.04)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
