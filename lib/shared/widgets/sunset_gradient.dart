import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The signature DriveTN hero gradient: coral → amber, 135°.
/// Wraps a child with the gradient as a background.
/// Optional radial glow overlay (top-right) adds depth.
class SunsetGradient extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool radialGlow;
  final double? height;

  const SunsetGradient({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.radialGlow = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      clipBehavior:
          borderRadius == null ? Clip.none : Clip.antiAlias,
      child: radialGlow
          ? Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  top: -60,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}
