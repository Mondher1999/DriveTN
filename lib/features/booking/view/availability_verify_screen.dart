import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Availability verification screen — "wow" animation moment.
/// Shown between date selection and booking flow to simulate
/// a real-time availability check with premium motion design.
class AvailabilityVerifyScreen extends StatefulWidget {
  final String carId;
  const AvailabilityVerifyScreen({super.key, required this.carId});

  @override
  State<AvailabilityVerifyScreen> createState() => _AvailabilityVerifyScreenState();
}

class _AvailabilityVerifyScreenState extends State<AvailabilityVerifyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _rippleCtrl;
  Timer? _phase1Timer;
  Timer? _phase2Timer;
  Timer? _navigateTimer;
  int _phase = 0; // 0 = scanning, 1 = found, 2 = confirmed
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Phase transitions — 1.5s between each for premium feel
    _phase1Timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _phase = 1);
    });
    _phase2Timer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _phase = 2);
        HapticFeedback.mediumImpact();
      }
    });
    _navigateTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        context.pushReplacement('/booking/${widget.carId}/eligibility');
      }
    });
  }

  @override
  void dispose() {
    _phase1Timer?.cancel();
    _phase2Timer?.cancel();
    _navigateTimer?.cancel();
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // Cancel button
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            // ---- Orbiting rings + car icon ----
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ---- Outer blinking ring (clignotage visible) ----
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final breathe = 0.25 + (_pulseCtrl.value * 0.55);
                      return Container(
                        width: 148,
                        height: 148,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: breathe),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  // ---- Strong radial glow that pulses ----
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final size = 110 + (_pulseCtrl.value * 38);
                      final alpha = 0.22 + (_pulseCtrl.value * 0.18);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: alpha),
                              AppColors.accent.withValues(alpha: alpha * 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                  // ---- Ripple rings (subtil) ----
                  ...List.generate(2, (i) {
                    return AnimatedBuilder(
                      animation: _rippleCtrl,
                      builder: (_, __) {
                        final t = ((_rippleCtrl.value + i / 2) % 1.0);
                        final eased = Curves.easeOutCubic.transform(t);
                        final opacity = ((1 - eased) * 0.45).clamp(0.0, 1.0);
                        final ringAlpha = (0.35 * (1 - eased)).clamp(0.0, 1.0);
                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 72 + eased * 48,
                            height: 72 + eased * 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withValues(
                                alpha: 0.10 * (1 - eased),
                              ),
                              border: Border.all(
                                color: AppColors.accent.withValues(
                                  alpha: ringAlpha,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  // Inner glow pulse
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      return Container(
                        width: 100 + (_pulseCtrl.value * 20),
                        height: 100 + (_pulseCtrl.value * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.15 + (_pulseCtrl.value * 0.1)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Car icon with status
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _phase == 2
                          ? const Icon(
                              LucideIcons.check,
                              key: ValueKey('check'),
                              size: 32,
                              color: AppColors.surface,
                            )
                          : const Icon(
                              LucideIcons.car,
                              key: ValueKey('car'),
                              size: 28,
                              color: AppColors.surface,
                            ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // ---- Status text ----
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child:                   _phase == 0
                  ? _statusText(
                      key: 'scanning',
                      label: 'Vérification de la disponibilité...',
                      sublabel: 'Recherche des meilleures offres',
                    )
                  : _phase == 1
                      ? _statusText(
                          key: 'found',
                          label: 'Voiture disponible !',
                          sublabel: 'Vérification des tarifs',
                        )
                      : _statusText(
                          key: 'confirmed',
                          label: 'Disponibilité confirmée',
                          sublabel: 'Préparation de votre expérience',
                        ),
            ),
            const SizedBox(height: 24),
            // ---- Progress dots ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(active: _phase >= 0),
                const SizedBox(width: 8),
                _dot(active: _phase >= 1),
                const SizedBox(width: 8),
                _dot(active: _phase >= 2),
              ],
            ),
          ],
        ),
      ),
    ],
  )
),
));
}

  Widget _statusText({required String key, required String label, required String sublabel}) {
    return Column(
      key: ValueKey(key),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.h1(
            size: 22,
            weight: FontWeight.w800,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.2, end: 0, duration: 300.ms),
        const SizedBox(height: 8),
        Text(
          sublabel,
          style: AppTypography.body(
            size: 14,
            color: AppColors.textMuted,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.15, end: 0, delay: 100.ms),
      ],
    );
  }

  Widget _dot({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              )
            : null,
        color: active ? null : AppColors.borderStrong,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
