import 'dart:async';
import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Agency validation screen with animated chronometer.
/// Shown between identity scan and payment while agency reviews the booking.
class AgencyValidationScreen extends StatefulWidget {
  final String carId;
  const AgencyValidationScreen({super.key, required this.carId});

  @override
  State<AgencyValidationScreen> createState() => _AgencyValidationScreenState();
}

class _AgencyValidationScreenState extends State<AgencyValidationScreen>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 60; // 5 minutes
  int _elapsed = 0;
  Timer? _timer;

  late final AnimationController _chronometerCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _tickCtrl;

  // Phase-based text
  String get _statusText {
    if (_elapsed < 60) {
      return "Nous avons notifié l'agence de votre demande...";
    } else if (_elapsed < 180) {
      return "L'agence examine votre dossier en ce moment...";
    } else if (_elapsed < 240) {
      return "Presque terminé, nous finalisons les détails...";
    } else {
      return "Validation imminente, préparez-vous au paiement...";
    }
  }

  String get _phaseLabel {
    if (_elapsed < 60) return 'NOTIFICATION';
    if (_elapsed < 180) return 'EXAMEN';
    if (_elapsed < 240) return 'FINALISATION';
    return 'VALIDATION';
  }

  @override
  void initState() {
    super.initState();

    // Chronometer hand rotates continuously (1 revolution = 1 second)
    _chronometerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Pulsing glow
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Tick sound effect controller
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
      });
      _tickCtrl.forward(from: 0);
      if (_elapsed >= _totalSeconds) {
        _timer?.cancel();
        _goToPayment();
      }
    });
  }

  void _goToPayment() {
    if (mounted) {
      context.go('/booking/${widget.carId}/payment');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _chronometerCtrl.dispose();
    _pulseCtrl.dispose();
    _tickCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalSeconds - _elapsed;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final progress = _elapsed / _totalSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient floating orbs
          _FloatingOrbs(),

          SafeArea(
            child: Column(
              children: [
                // Top bar with cancel
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      const Spacer(),
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
                          child: const Icon(
                            LucideIcons.x,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // ===== ANIMATED CHRONOMETER =====
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow pulse
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return Container(
                            width: 240 + (_pulseCtrl.value * 20),
                            height: 240 + (_pulseCtrl.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(
                                    alpha: 0.08 + (_pulseCtrl.value * 0.08),
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Outer ring with tick marks
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _ChronometerTicksPainter(),
                      ),

                      // Progress ring
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CustomPaint(
                              size: const Size(220, 220),
                              painter: _ProgressRingPainter(
                                progress: value,
                                color: AppColors.accent,
                              ),
                            );
                          },
                        ),
                      ),

                      // Rotating hand (chronometer needle)
                      AnimatedBuilder(
                        animation: _chronometerCtrl,
                        builder: (_, __) {
                          return Transform.rotate(
                            angle: _chronometerCtrl.value * 2 * pi,
                            child: Container(
                              width: 220,
                              height: 220,
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 3,
                                height: 90,
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Center dot
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Timer text inside
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$minutes:$seconds',
                            style: AppTypography.numeric(
                              size: 42,
                              weight: FontWeight.w900,
                              color: AppColors.ink,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'min restantes',
                            style: AppTypography.caps(
                              size: 9,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 700.ms, delay: 300.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 800.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 40),

                // Phase label
                AnimatedSwitcher(
                  duration: 600.ms,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _phaseLabel,
                    key: ValueKey(_phaseLabel),
                    style: AppTypography.caps(
                      size: 11,
                      letterSpacing: 3,
                      color: AppColors.accent,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                const SizedBox(height: 12),

                // Status text card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface.withValues(alpha: 0.7),
                        AppColors.surface.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: 600.ms,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _statusText,
                      key: ValueKey(_statusText),
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 15,
                        weight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0, delay: 800.ms),

                const Spacer(flex: 2),

                // Play-while-waiting CTA
                GestureDetector(
                  onTap: () => context.push('/booking/${widget.carId}/game'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.gamepad2,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Jouer en attendant',
                          style: AppTypography.body(
                            size: 15,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 900.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      delay: 900.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true, period: 2000.ms))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.04, 1.04),
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 16),

                // Info notice about timeout / email fallback
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 14,
                        color: AppColors.accent.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Si l'agence met du temps, on vous notifiera par email et notification pour confirmer votre paiement.",
                          style: AppTypography.body(
                            size: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 1000.ms)
                    .slideY(begin: 0.15, end: 0, delay: 1000.ms),

                const SizedBox(height: 20),

                // Bottom shimmer hint
                Text(
                  'Ne quittez pas cette page',
                  style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                ).animate(onPlay: (c) => c.repeat(period: 2400.ms)).shimmer(
                      duration: 1200.ms,
                      color: AppColors.accent.withValues(alpha: 0.15),
                      delay: 400.ms,
                    ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Floating ambient orbs
// ─────────────────────────────────────────────
class _FloatingOrbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.12),
                    AppColors.gradientEnd.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientEnd.withValues(alpha: 0.10),
                    AppColors.gradientStart.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tick marks painter (chronometer face)
// ─────────────────────────────────────────────
class _ChronometerTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw tick marks
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (pi / 180); // 6 degrees per tick
      final isMainTick = i % 5 == 0;
      final tickLength = isMainTick ? 12.0 : 6.0;
      final tickWidth = isMainTick ? 2.0 : 1.0;
      final tickColor = isMainTick
          ? AppColors.ink.withValues(alpha: 0.3)
          : AppColors.ink.withValues(alpha: 0.1);

      final start = Offset(
        center.dx + (radius - 20) * cos(angle - pi / 2),
        center.dy + (radius - 20) * sin(angle - pi / 2),
      );
      final end = Offset(
        center.dx + (radius - 20 - tickLength) * cos(angle - pi / 2),
        center.dy + (radius - 20 - tickLength) * sin(angle - pi / 2),
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = tickColor
          ..strokeWidth = tickWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Progress ring painter
// ─────────────────────────────────────────────
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = AppColors.border.withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
