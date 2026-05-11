import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class SearchChoiceScreen extends StatelessWidget {
  const SearchChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Header
              Text(
                '— COMMENT CHERCHER ?',
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 3,
                  color: AppColors.accent,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: AppTypography.display(
                    size: 34,
                    weight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                  children: [
                    const TextSpan(text: 'Trouvez votre'),
                    const WidgetSpan(child: SizedBox(width: 8)),
                    TextSpan(
                      text: 'voiture.',
                      style: AppTypography.display(
                        size: 34,
                        weight: FontWeight.w300,
                        italic: true,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: 8),
              Text(
                'Deux façons de découvrir les véhicules disponibles près de vous.',
                style: AppTypography.body(
                  size: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 40),

              // Option 1: Simple search
              _ChoiceCard(
                icon: LucideIcons.search,
                title: 'Recherche simple',
                subtitle:
                    'Accédez directement à la liste et à la carte. Appliquez vos filtres en un clin d\'œil.',
                badge: 'RAPIDE',
                delay: 300.ms,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/home/explorer');
                },
              ),

              const SizedBox(height: 16),

              // Option 2: Guided wizard
              _ChoiceCard(
                icon: LucideIcons.sparkles,
                title: 'Questions guidées',
                subtitle:
                    'Répondez à 8 questions sur votre besoin. Nous trouvons la voiture idéale pour vous.',
                badge: 'PERSONNALISÉ',
                isAccent: true,
                delay: 450.ms,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/wizard');
                },
              ),

              const Spacer(),

              // Bottom hint
              Center(
                child: Text(
                  'Vous pouvez changer d\'avis à tout moment',
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final bool isAccent;
  final Duration delay;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.isAccent = false,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isAccent
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.softWarm.withValues(alpha: 0.45),
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAccent ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          boxShadow: isAccent
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isAccent
                    ? AppColors.surface.withValues(alpha: 0.22)
                    : AppColors.softWarm,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isAccent ? AppColors.surface : AppColors.accent,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.h2(
                            size: 18,
                            weight: FontWeight.w800,
                            color: isAccent ? AppColors.surface : AppColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAccent
                              ? AppColors.surface.withValues(alpha: 0.22)
                              : AppColors.ink,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: AppTypography.caps(
                            size: 9,
                            letterSpacing: 1.2,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w500,
                      color: isAccent
                          ? AppColors.surface.withValues(alpha: 0.9)
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowRight,
              size: 20,
              color: isAccent
                  ? AppColors.surface.withValues(alpha: 0.8)
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: delay);
  }
}
