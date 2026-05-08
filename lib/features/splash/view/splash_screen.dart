import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SunsetGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DRIVETN  ·  TUNIS  ·  2026',
                  style: AppTypography.caps(
                    size: 10,
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms),
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1.0, end: -2.4),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, ls, __) => Text(
                    'Drive,',
                    style: AppTypography.display(
                      size: 72,
                      weight: FontWeight.w900,
                      color: AppColors.surface,
                      letterSpacing: ls,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1.0, end: -2.4),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, ls, __) => Text(
                    'differently.',
                    style: AppTypography.display(
                      size: 56,
                      weight: FontWeight.w300,
                      italic: true,
                      color: AppColors.surface.withValues(alpha: 0.92),
                      letterSpacing: ls,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
                    .shimmer(
                      duration: 1800.ms,
                      delay: 1600.ms,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                const SizedBox(height: 24),
                Container(
                  width: 36,
                  height: 2,
                  color: AppColors.surface.withValues(alpha: 0.6),
                )
                    .animate()
                    .scaleX(
                      begin: 0,
                      end: 1,
                      delay: 900.ms,
                      duration: 500.ms,
                      alignment: Alignment.centerLeft,
                    ),
                const SizedBox(height: 16),
                Text(
                  'La voiture, sans friction.',
                  style: AppTypography.body(
                    size: 14,
                    color: AppColors.surface.withValues(alpha: 0.85),
                    weight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 500.ms),
                const Spacer(),
                Text(
                  'CARTHAGE  ·  LA MARSA  ·  LAC  ·  ARIANA',
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 3,
                    color: AppColors.surface.withValues(alpha: 0.5),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
