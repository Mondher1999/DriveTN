import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { ink, light, ghost, gradient, accent }

enum IconPosition { left, right }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final ButtonVariant variant;
  final Color? color;
  final IconPosition iconPosition;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = ButtonVariant.ink,
    this.color,
    this.iconPosition = IconPosition.right,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;

    Color? bg;
    Gradient? gradient;
    Color fg;
    Color borderColor;
    switch (variant) {
      case ButtonVariant.ink:
        bg = color ?? AppColors.ink;
        fg = AppColors.surface;
        borderColor = bg;
        break;
      case ButtonVariant.accent:
        bg = AppColors.accent;
        fg = AppColors.surface;
        borderColor = bg;
        break;
      case ButtonVariant.light:
        bg = AppColors.surface;
        fg = AppColors.ink;
        borderColor = AppColors.borderStrong;
        break;
      case ButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.ink;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.gradient:
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        );
        fg = AppColors.surface;
        borderColor = Colors.transparent;
        bg = null;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedOpacity(
        opacity: disabled ? 0.55 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: disabled ? AppColors.borderStrong : bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: disabled ? AppColors.border : borderColor,
              width: 1,
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled ? null : gradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: disabled
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    },
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null && iconPosition == IconPosition.left) ...[
                            Icon(icon, size: 18, color: fg),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            label,
                            style: AppTypography.body(
                              size: 15,
                              weight: FontWeight.w700,
                              color: fg,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (icon != null && iconPosition == IconPosition.right) ...[
                            const SizedBox(width: 10),
                            Icon(icon, size: 18, color: fg),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
