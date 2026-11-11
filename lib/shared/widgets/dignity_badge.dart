import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

enum DignityBadgeVariant {
  verified,
  confidential,
  discreet,
  urgent,
  neutral,
  success,
}

class DignityBadge extends StatelessWidget {
  final String text;
  final Widget? icon;
  final DignityBadgeVariant variant;

  const DignityBadge({
    super.key,
    required this.text,
    this.icon,
    this.variant = DignityBadgeVariant.verified,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case DignityBadgeVariant.verified:
        bg = const Color(0xFFDCF8EC);
        fg = AppColors.success;
        break;
      case DignityBadgeVariant.confidential:
      case DignityBadgeVariant.discreet:
        bg = AppColors.softLavender;
        fg = AppColors.primaryContainer;
        break;
      case DignityBadgeVariant.urgent:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        break;
      case DignityBadgeVariant.success:
        bg = const Color(0xFFDCF8EC);
        fg = AppColors.success;
        break;
      case DignityBadgeVariant.neutral:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.neutralMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.labelSM(color: fg),
          ),
        ],
      ),
    );
  }
}
