import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class ReturnSuccessScreen extends StatefulWidget {
  final String bookingId;
  const ReturnSuccessScreen({super.key, required this.bookingId});

  @override
  State<ReturnSuccessScreen> createState() =>
      _ReturnSuccessScreenState();
}

class _ReturnSuccessScreenState extends State<ReturnSuccessScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = MockData.bookingById(widget.bookingId);
    final car = booking != null ? MockData.carById(booking.carId) : null;
    final days = booking?.durationDays ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._irradiate(),
                    ..._particles(),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                      ),
                      child: const Icon(LucideIcons.check,
                          color: AppColors.surface, size: 48),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 600.ms,
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '— LOCATION TERMINÉE',
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 3,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Column(
                children: [
                  Text(
                    'Bonne',
                    style: AppTypography.display(
                      size: 56,
                      weight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    'route.',
                    style: AppTypography.display(
                      size: 56,
                      weight: FontWeight.w300,
                      italic: true,
                      letterSpacing: -2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                car == null
                    ? 'Merci pour votre voyage.'
                    : 'Merci pour votre voyage avec la ${car.model}.',
                style: AppTypography.body(
                    size: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _row('DURÉE TOTALE',
                      '$days jour${days > 1 ? 's' : ''}'),
                  _divider(),
                  _row('KM PARCOURUS', '142'),
                  _divider(),
                  _stateRow(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '— VOTRE EXPÉRIENCE',
                    style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 3,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Comment s'est passée la course ?",
                    style: AppTypography.h2(size: 18),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () => setState(() => _rating = i),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              i <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 38,
                              color: i <= _rating
                                  ? AppColors.accent
                                  : AppColors.borderStrong,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Un mot à laisser ?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Envoyer',
                    variant: ButtonVariant.light,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Merci pour votre avis')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: "Retour à l'accueil",
              icon: LucideIcons.arrowRight,
              variant: ButtonVariant.gradient,
              onPressed: () => context.go('/home/explorer'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTypography.caps(size: 10, color: AppColors.textMuted)),
          ),
          Text(value, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _stateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text('ÉTAT',
                style: AppTypography.caps(size: 10, color: AppColors.textMuted)),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('Aucun dégât détecté',
              style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.border);

  List<Widget> _particles() {
    return List.generate(12, (i) {
      // angle is computed but we use precomputed dx/dy for simplicity
      // ignore: unused_local_variable
      final angle = (i * math.pi * 2) / 12;
      final dx = 80 * (i.isEven ? 1 : -1) * (i % 3 == 0 ? 1.0 : 0.7);
      final dy = 80 * (i.isOdd ? 1 : -1) * (i % 4 == 0 ? 1.0 : 0.6);
      final color =
          i.isEven ? AppColors.gradientStart : AppColors.gradientEnd;
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      )
          .animate(delay: 700.ms)
          .moveX(begin: 0, end: dx, duration: 900.ms, curve: Curves.easeOut)
          .moveY(begin: 0, end: dy, duration: 900.ms, curve: Curves.easeOut)
          .fadeOut(duration: 900.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.4, 0.4),
            duration: 900.ms,
          );
    });
  }

  List<Widget> _irradiate() {
    return List.generate(3, (i) {
      final delay = (i * 280).ms;
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.6, 1.6),
            duration: 1800.ms,
            delay: delay,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 1800.ms, delay: delay);
    });
  }
}
