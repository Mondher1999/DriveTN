import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: SunsetGradient(
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '— 01',
                            style: AppTypography.caps(
                              size: 10,
                              letterSpacing: 3,
                              color: AppColors.surface,
                            ),
                          ),
                          Text(
                            'TUNIS · 2026',
                            style: AppTypography.caps(
                              size: 9,
                              letterSpacing: 2.4,
                              color: AppColors.surface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Drive,',
                        style: AppTypography.display(
                          size: 56,
                          color: AppColors.surface,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      Text(
                        'differently.',
                        style: AppTypography.display(
                          size: 56,
                          weight: FontWeight.w300,
                          italic: true,
                          color: AppColors.surface
                              .withValues(alpha: 0.95),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      Container(
                        width: 36,
                        height: 1,
                        color: AppColors.surface
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 280,
                        child: Text(
                          'La marketplace tunisienne pour louer, '
                          'conduire, et profiter — sans friction.',
                          style: AppTypography.body(
                            size: 15,
                            weight: FontWeight.w500,
                            color: AppColors.surface
                                .withValues(alpha: 0.92),
                            height: 1.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const Spacer(),
                      SizedBox(
                        height: 22,
                        child: ClipRect(
                          child: OverflowBox(
                            maxWidth: 9999,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                4,
                                (_) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 32),
                                  child: Text(
                                    '·  240 VOITURES  ·  6 VILLES  ·  0% FRICTION  ·  ASSURANCE INCLUSE  ',
                                    style: AppTypography.caps(
                                      size: 11,
                                      letterSpacing: 2,
                                      color: AppColors.surface
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat())
                                .slideX(
                                  begin: 0,
                                  end: -0.5,
                                  duration: 18.seconds,
                                  curve: Curves.linear,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'BIENVENUE',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Prêt à prendre la route ?',
                      style: AppTypography.h1(
                        size: 22,
                        weight: FontWeight.w800,
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Continuer en démo',
                      icon: LucideIcons.arrowRight,
                      variant: ButtonVariant.gradient,
                      onPressed: () => context.go('/wizard'),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Mode démonstration · aucun compte requis',
                        style: AppTypography.body(
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
