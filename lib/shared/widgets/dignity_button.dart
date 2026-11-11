import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

enum DignityButtonStyle {
  primary,
  secondary,
  accent,
  outline,
  text,
}

class DignityButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final DignityButtonStyle style;
  final Widget? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const DignityButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = DignityButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.height = 48.0,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (style) {
      case DignityButtonStyle.primary:
        bg = AppColors.primaryContainer;
        fg = AppColors.onPrimary;
        break;
      case DignityButtonStyle.secondary:
        bg = AppColors.softLavender;
        fg = AppColors.primaryContainer;
        break;
      case DignityButtonStyle.accent:
        bg = AppColors.coralPink;
        fg = AppColors.onPrimary;
        break;
      case DignityButtonStyle.outline:
        bg = Colors.transparent;
        fg = AppColors.primaryContainer;
        side = const BorderSide(color: AppColors.borderSubtle, width: 1.5);
        break;
      case DignityButtonStyle.text:
        bg = Colors.transparent;
        fg = AppColors.primaryContainer;
        break;
    }

    Widget content = Row(
      mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.labelLG(color: fg),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
          side: side,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.buttonBorder,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          ),
        ),
      ),
    );
  }
}
