import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class KeylessInfoScreen extends StatelessWidget {
  final String carId;
  const KeylessInfoScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final car = MockData.carById(carId);
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final safeBottom = mq.padding.bottom;
    final isCompact = screenHeight < 820;
    final imageSize = isCompact ? 200.0 : 220.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.fromLTRB(20, isCompact ? 8 : 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Partage — mode démo')),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.share2,
                          size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Car name centered
            if (car != null)
              Text(
                '${car.brand} ${car.model}',
                style: AppTypography.body(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo + bluetooth icon overlap
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: car != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFFE4D6),
                                                Color(0xFFFFF1B8),
                                              ],
                                            ),
                                          ),
                                        ),
                                        CachedNetworkImage(
                                          imageUrl: car.photoUrls.first,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(
                                            LucideIcons.car,
                                            size: 64,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFE4D6),
                                            Color(0xFFFFF1B8),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        LucideIcons.car,
                                        size: 64,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: -16,
                            bottom: -16,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.accent.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.bluetooth,
                                size: 32,
                                color: AppColors.surface,
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.08, 1.08),
                                  duration: 1400.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 500.ms,
                        ),
                    SizedBox(height: isCompact ? 20 : 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            'Déverrouillez',
                            style: AppTypography.display(
                              size: 28,
                              weight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    Text(
                      'avec votre smartphone.',
                      style: AppTypography.display(
                        size: 28,
                        weight: FontWeight.w300,
                        italic: true,
                        letterSpacing: -1.2,
                        height: 1.05,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 250.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: isCompact ? 16 : 24),
                    _bullet(
                      icon: LucideIcons.shieldCheck,
                      title: "Pas besoin de rencontrer qui que ce soit",
                      subtitle:
                          "Vous seul pouvez déverrouiller la voiture grâce à notre technologie Bluetooth sécurisée.",
                      delay: 350,
                    ),
                    const SizedBox(height: 14),
                    _bullet(
                      icon: LucideIcons.smartphone,
                      title: "Inspectez vous-même la voiture",
                      subtitle:
                          "Prenez et envoyez les photos de l'état de la voiture avant et après votre location.",
                      delay: 450,
                    ),
                    const SizedBox(height: 14),
                    _bullet(
                      icon: LucideIcons.parkingSquare,
                      title: "Ramenez la voiture au même endroit",
                      subtitle:
                          "Verrouillez la voiture avec l'application à la fin de votre course.",
                      delay: 550,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, safeBottom + (isCompact ? 8 : 16)),
              child: PrimaryButton(
                label: "D'accord, continuer",
                icon: LucideIcons.arrowRight,
                variant: ButtonVariant.gradient,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/booking/$carId');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softWarm,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
