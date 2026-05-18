import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class SimulationReadyModal extends StatelessWidget {
  const SimulationReadyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: const SimulationReadyModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = MockData.carById('c2');
    final carName = car != null ? '${car.brand} ${car.model}' : 'Votre véhicule';
    final now = DateTime.now();
    final startDate = now.add(const Duration(minutes: 8));
    final endDate = now.add(const Duration(days: 2));
    final df = DateFormat('d MMM', 'fr_FR');
    final dates = '${df.format(startDate)} → ${df.format(endDate)}';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStart.withValues(alpha: 0.15),
              blurRadius: 60,
              spreadRadius: -10,
              offset: const Offset(0, 24),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtle top gradient accent line
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softWarm,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SIMULATION',
                            style: AppTypography.caps(
                              size: 9,
                              letterSpacing: 1.5,
                              color: AppColors.gradientStart,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            LucideIcons.x,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Car icon - minimal, line style
                    const Icon(
                      LucideIcons.car,
                      size: 56,
                      color: AppColors.gradientStart,
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      carName,
                      style: AppTypography.display(
                        size: 24,
                        weight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'est prête',
                      style: AppTypography.display(
                        size: 24,
                        weight: FontWeight.w300,
                        italic: true,
                        color: AppColors.gradientStart,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.gradientStart,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Départ dans ~15 minutes',
                          style: AppTypography.body(
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Dates - minimal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dates,
                            style: AppTypography.body(
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // CTA Button - modern rounded rect
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        context.go('/simulation/map/c2');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gradientStart.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Déverrouiller ma voiture',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtle hint
                    Text(
                      'Ceci est une simulation de votre Jour J',
                      style: AppTypography.body(
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0, duration: 350.ms);
  }
}
