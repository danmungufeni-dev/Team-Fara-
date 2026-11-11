import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Adaptive layout manager adhering to padcare/DESIGN.md grid rules.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double maxContentWidth;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxContentWidth = 640.0,
  });

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return DeviceType.desktop;
    if (width > 500) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static double horizontalPadding(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
      case DeviceType.tablet:
        return AppSpacing.marginTablet;
      case DeviceType.mobile:
        return AppSpacing.margin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900 && desktop != null) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth * 1.5),
              child: desktop!,
            ),
          );
        }

        if (constraints.maxWidth > 500 && tablet != null) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth * 1.2),
              child: tablet!,
            ),
          );
        }

        // Standard mobile container centered on desktop/web
        if (constraints.maxWidth > maxContentWidth) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: mobile,
            ),
          );
        }

        return mobile;
      },
    );
  }
}
