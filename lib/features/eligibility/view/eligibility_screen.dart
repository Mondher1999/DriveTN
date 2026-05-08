import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class EligibilityScreen extends StatelessWidget {
  final String carId;
  const EligibilityScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.x,
                          size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero illustration card (gradient softWarm with shield-check)
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.shieldCheck,
                          size: 64,
                          color: AppColors.surface,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 500.ms,
                        ),
                    const SizedBox(height: 28),
                    Text(
                      '— ÉLIGIBILITÉ',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.accent,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            'Vérifions',
                            style: AppTypography.display(
                              size: 32,
                              weight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                    Text(
                      'si vous êtes éligible.',
                      style: AppTypography.display(
                        size: 32,
                        weight: FontWeight.w300,
                        italic: true,
                        letterSpacing: -1.4,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    Text(
                      'Pour louer cette voiture, vous devez :',
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 14),
                    // Requirement rows
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _requirementRow(
                            icon: LucideIcons.userCheck,
                            label: 'Avoir au moins 18 ans',
                          ),
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            color: AppColors.border,
                          ),
                          _requirementRow(
                            icon: LucideIcons.creditCard,
                            label: 'Avoir le permis depuis au moins 2 ans',
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 16),
                    // Info banner — softWarm card with corail border
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.softWarm,
                            AppColors.softWarm.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.lightbulb,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "En vérifiant votre âge et votre permis, nous pouvons vous montrer des voitures qui correspondent à votre profil.",
                              style: AppTypography.body(
                                size: 12,
                                color: AppColors.textSecondary,
                                weight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.06, end: 0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: PrimaryButton(
                label: 'Commencer',
                icon: LucideIcons.arrowRight,
                variant: ButtonVariant.gradient,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/booking/$carId/keyless-info');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requirementRow({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softWarm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.check,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
