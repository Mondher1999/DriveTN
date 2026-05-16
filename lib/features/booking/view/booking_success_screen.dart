import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/booking_cubit.dart';
import 'pickup_guide_sheet.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String carId;
  const BookingSuccessScreen({super.key, required this.carId});

  String _fmt(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d);

  @override
  Widget build(BuildContext context) {
    final state = context.read<BookingCubit>().state;
    final booking = state.confirmedBooking ??
        (MockData.bookings.isNotEmpty ? MockData.bookings.last : null);
    final car = booking != null ? MockData.carById(booking.carId) : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home/rentals');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
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
                          child: const Icon(
                            LucideIcons.check,
                            color: AppColors.surface,
                            size: 48,
                          ),
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
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Location confirmée',
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "C'est",
                        style: AppTypography.display(
                          size: 56,
                          weight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        'parti.',
                        style: AppTypography.display(
                          size: 56,
                          weight: FontWeight.w300,
                          italic: true,
                          letterSpacing: -2,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    car == null
                        ? 'Votre véhicule vous attend.'
                        : 'Votre ${car.brand} ${car.model} vous attend.',
                    style: AppTypography.body(
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ),
                const SizedBox(height: 28),
                if (booking != null && car != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _row('VÉHICULE', '${car.brand} ${car.model}'),
                        _divider(),
                        _row('DATES',
                            '${_fmt(booking.startDate)} → ${_fmt(booking.endDate)}'),
                        _divider(),
                        _row(
                          'RÉFÉRENCE',
                          'DT-${booking.id.toUpperCase().substring(0, booking.id.length > 6 ? 6 : booking.id.length)}',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                const Spacer(),
                if (booking != null)
                  PrimaryButton(
                    label: 'Voir le guide de prise en charge',
                    icon: LucideIcons.bookOpen,
                    variant: ButtonVariant.gradient,
                    onPressed: () => PickupGuideSheet.show(context),
                  ).animate().fadeIn(delay: 1100.ms),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home/rentals'),
                  child: Text(
                    'Plus tard',
                    style: AppTypography.body(
                      size: 14,
                      color: AppColors.textMuted,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                style: AppTypography.body(size: 11, weight: FontWeight.w600, color: AppColors.textMuted)),
          ),
          Text(value, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
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
