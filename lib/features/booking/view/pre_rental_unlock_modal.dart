import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class PreRentalUnlockModal extends StatelessWidget {
  const PreRentalUnlockModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PreRentalUnlockModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              // Header with close/skip
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Passer',
                    style: AppTypography.body(
                      size: 14,
                      color: AppColors.textSecondary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Hero section
              _buildHeroSection(),
              const SizedBox(height: 24),
              // Rental info card
              _buildInfoCard(),
              const Spacer(),
              // CTA button
              _buildCtaButton(context),
              const SizedBox(height: 12),
              // Secondary link
              _buildSecondaryLink(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Big animated car icon in a gradient circle
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: const Icon(
            LucideIcons.car,
            color: AppColors.surface,
            size: 32,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
              duration: 600.ms,
            ),
        const SizedBox(height: 16),
        Text(
          'Votre Peugeot 208 est prête',
          style: AppTypography.display(size: 22, weight: FontWeight.w800),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              delay: -400.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 8),
        Text(
          'Votre location commence dans 15 minutes',
          style: AppTypography.body(size: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
              delay: -400.ms,
              curve: Curves.easeOut,
            ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(LucideIcons.calendar, '21 mai → 24 mai'),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.mapPin, 'Agence centre-ville'),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.clock, 'Récupération : 09:00'),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: -500.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTypography.body(size: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.go('/inspection/pickup/demo-booking');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStart.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.navigation,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Localiser ma voiture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 0.4,
          end: 0,
          duration: 500.ms,
          delay: 700.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(
          duration: 500.ms,
          delay: -500.ms,
        );
  }

  Widget _buildSecondaryLink() {
    return GestureDetector(
      onTap: () {
        // TODO: navigate to pickup guide
      },
      child: Text(
        'Voir la localisation de ma voiture',
        style: AppTypography.body(
          size: 13,
          color: AppColors.gradientStart,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
