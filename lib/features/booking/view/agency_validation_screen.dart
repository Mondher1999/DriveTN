import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Agency validation screen.
/// Shown between identity scan and payment while agency reviews the booking.
class AgencyValidationScreen extends StatefulWidget {
  final String carId;
  const AgencyValidationScreen({super.key, required this.carId});

  @override
  State<AgencyValidationScreen> createState() => _AgencyValidationScreenState();
}

class _AgencyValidationScreenState extends State<AgencyValidationScreen>
    with TickerProviderStateMixin {
  static const int _totalSeconds = 80; // 20 seconds per step
  int _elapsed = 0;
  Timer? _timer;

  late final AnimationController _pulseCtrl;
  AnimationController? _wipeCtrl;

  // Dynamic hero title based on current step
  (String, String) _getHeroTitle(double progress) {
    final step = (progress * 4).floor().clamp(0, 3);
    return switch (step) {
      0 => ('En attente', 'de validation...'),
      1 => ('L\'agence', 'examine votre demande...'),
      2 => ('Validation', 'en cours...'),
      _ => ('C\'est', 'presque prêt !'),
    };
  }

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _wipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
      });
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
    _pulseCtrl.dispose();
    _wipeCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsed / _totalSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _FloatingOrbs(),
          SafeArea(
            child: Column(
              children: [
                // Top bar with cancel
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.35),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hero title — changes with step
                          AnimatedSwitcher(
                            duration: 600.ms,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: Builder(
                              key: ValueKey((progress * 4).floor()),
                              builder: (_) {
                                final title = _getHeroTitle(progress);
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: title.$1,
                                          style: AppTypography.display(
                                            size: 28,
                                            weight: FontWeight.w900,
                                            letterSpacing: -1.2,
                                            height: 1.05,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ${title.$2}',
                                          style: AppTypography.display(
                                            size: 28,
                                            weight: FontWeight.w300,
                                            italic: true,
                                            letterSpacing: -1.2,
                                            height: 1.05,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(
                                  begin: 0.15, end: 0, delay: 200.ms),

                          const SizedBox(height: 36),

                          // Progress bar
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildStepProgress(progress),
                          )
                              .animate()
                              .fadeIn(duration: 700.ms, delay: 300.ms)
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 700.ms,
                                delay: 300.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 32),

                          // Step-specific status info
                          _buildStepInfo(progress),

                          const SizedBox(height: 32),

                          // Fidelity points hook
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.sparkles,
                                size: 15,
                                color: AppColors.gradientStart,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chaque partie = points de fidélité',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: AppColors.gradientStart,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 800.ms)
                              .slideY(
                                  begin: 0.1, end: 0, delay: 800.ms),

                          const SizedBox(height: 24),

                          // Play-while-waiting CTA — simplified particles for cleaner UI
                          GestureDetector(
                            onTap: () =>
                                context.push('/booking/${widget.carId}/game'),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  // Subtle ambient particles (reduced count & opacity)
                                  ...List.generate(4, (i) {
                                    final colors = [
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                    ];
                                    final sizes = [5.0, 6.0, 4.0, 7.0];
                                    final alignments = [
                                      const Alignment(-1.25, -0.45),
                                      const Alignment(1.25, -0.50),
                                      const Alignment(-1.15, 0.45),
                                      const Alignment(1.15, 0.50),
                                    ];
                                    return Align(
                                      alignment: alignments[i],
                                      child: Container(
                                        width: sizes[i],
                                        height: sizes[i],
                                        decoration: BoxDecoration(
                                          color: colors[i]
                                              .withValues(alpha: 0.35),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                          .animate(
                                              onPlay: (c) => c.repeat(
                                                  reverse: true,
                                                  period: Duration(
                                                      milliseconds:
                                                          1600 + i * 300)))
                                          .scale(
                                            begin: const Offset(0.5, 0.5),
                                            end: const Offset(1.1, 1.1),
                                            duration: const Duration(
                                                milliseconds: 800),
                                            curve: Curves.easeInOut,
                                          )
                                          .fade(
                                            begin: 0.2,
                                            end: 0.55,
                                            duration: const Duration(
                                                milliseconds: 800),
                                          ),
                                    );
                                  }),

                                  // Main button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
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
                                          color: AppColors.accent
                                              .withValues(alpha: 0.35),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          LucideIcons.gamepad2,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                            .animate(
                                                onPlay: (c) => c.repeat(
                                                    reverse: true,
                                                    period: 2400.ms))
                                            .rotate(
                                              begin: -0.12,
                                              end: 0.12,
                                              duration: 600.ms,
                                              curve: Curves.easeInOut,
                                            ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Jouez et gagnez des points',
                                          style: AppTypography.body(
                                            size: 14,
                                            weight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 700.ms, delay: 900.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 900.ms,
                                curve: Curves.easeOutBack,
                              )
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                                delay: 900.ms,
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              ),

                          const SizedBox(height: 28),

                          // Email fallback reassurance — icon + text for clarity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.mail,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Notification par email si nécessaire",
                                style: AppTypography.body(
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 1000.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step progress bar — continuous line with nodes for Gestalt continuity.
  /// Uses proximity law: label close to node, node close to connector.
  Widget _buildStepProgress(double progress) {
    final steps = [
      ('Notification', LucideIcons.bell),
      ('Examen', LucideIcons.fileSearch),
      ('Finalisation', LucideIcons.settings),
      ('Validation', LucideIcons.checkCircle),
    ];
    final currentStep =
        (progress * steps.length).floor().clamp(0, steps.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Connector line with nodes (continuity + common region) ──
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(steps.length * 2 - 1, (index) {
              final i = index ~/ 2;
              final isConnector = index.isOdd;

              if (isConnector) {
                // Line segment between nodes
                final isDone = i < currentStep;
                final isActive = i == currentStep;

                if (isActive) {
                  return Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background track
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.border.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        // Fill bar that enters left → right then repeats
                        if (_wipeCtrl != null)
                          AnimatedBuilder(
                            animation: _wipeCtrl!,
                            builder: (_, __) {
                              return FractionallySizedBox(
                                widthFactor: _wipeCtrl!.value,
                                alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDone
                          ? null
                          : AppColors.border.withValues(alpha: 0.35),
                      gradient: isDone
                          ? const LinearGradient(
                                colors: [
                                  AppColors.gradientStart,
                                  AppColors.gradientEnd,
                                ],
                              )
                            : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }

              // Node
              final isDone = i < currentStep;
              final isActive = i == currentStep;
              final isPending = i > currentStep;

              Widget node = AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // Similarity law: done = muted success tint; active = vibrant gradient; pending = neutral surface
                  color: isDone
                      ? AppColors.success.withValues(alpha: 0.12)
                      : (isPending ? AppColors.surface : null),
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        )
                      : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppColors.success.withValues(alpha: 0.45)
                        : (isActive
                            ? Colors.transparent
                            : AppColors.border.withValues(alpha: 0.6)),
                    width: isDone ? 2.0 : 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                AppColors.gradientStart.withValues(alpha: 0.30),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: AppColors.success,
                        )
                      : isActive
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Icon(
                              steps[i].$2,
                              size: 15,
                              color: AppColors.textMuted,
                            ),
                ),
              );

              if (isActive) {
                node = AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final scale = 1.0 + (_pulseCtrl.value * 0.10);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 40,
                        height: 40,
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
                              color: AppColors.gradientStart.withValues(
                                alpha: 0.35 + (_pulseCtrl.value * 0.35),
                              ),
                              blurRadius: 18 + (_pulseCtrl.value * 14),
                              spreadRadius: 2 + (_pulseCtrl.value * 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 10 + (_pulseCtrl.value * 4),
                            height: 10 + (_pulseCtrl.value * 4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return node;
            }),
          ),
        ),

        // Proximity law: keep labels very close to their nodes
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (i) {
            final isDone = i < currentStep;
            final isActive = i == currentStep;
            final color = isDone
                ? AppColors.success
                : (isActive ? AppColors.gradientStart : AppColors.textMuted);
            return Expanded(
              child: Text(
                steps[i].$1,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 11,
                  weight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Step-specific info — changes every ~15s (4 steps × 15s = 60s total)
  Widget _buildStepInfo(double progress) {
    final stepMessages = [
      (
        'Notification envoyée',
        "L'agence a été alertée de votre demande de location.",
        LucideIcons.bell,
      ),
      (
        'Examen en cours',
        "Votre dossier et documents sont en cours de vérification.",
        LucideIcons.fileSearch,
      ),
      (
        'Finalisation',
        "Nous préparons la confirmation et les détails de la réservation.",
        LucideIcons.settings,
      ),
      (
        'Validation imminente',
        "C'est presque prêt ! Préparez-vous au paiement.",
        LucideIcons.checkCircle,
      ),
    ];
    final stepIndex = (progress * 4).floor().clamp(0, 3);
    final msg = stepMessages[stepIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(stepIndex),
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.035),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge for instant recognition (common region + similarity)
            Container(
              width: 44,
              height: 44,
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
                    color: AppColors.gradientStart.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  msg.$3,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              msg.$1,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.gradientStart,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg.$2,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
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