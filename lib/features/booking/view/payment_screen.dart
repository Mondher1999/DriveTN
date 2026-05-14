import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/price_tag.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';

class PaymentScreen extends StatelessWidget {
  final String carId;
  const PaymentScreen({super.key, required this.carId});

  String _short(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final horizontalPadding = size.width < 380 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final car = state.car;
          final deposit = car?.depositAmount ?? 0;

          return SafeArea(
            child: Stack(
              children: [
                // Ambient background glow
                Positioned(
                  top: -size.height * 0.15,
                  right: -size.width * 0.2,
                  child: Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gradientStart.withValues(alpha: 0.08),
                          AppColors.gradientEnd.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main scrollable content
                CustomScrollView(
                  slivers: [
                    // Top bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            horizontalPadding, 12, horizontalPadding, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context
                                  .go('/booking/$carId/agency-validation'),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink
                                          .withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.arrowLeft,
                                  size: 18,
                                  color: AppColors.ink,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: -0.2, end: 0, duration: 300.ms),
                            const Spacer(),
                            Text(
                              '— PAIEMENT',
                              style: AppTypography.caps(
                                size: 11,
                                letterSpacing: 2.4,
                                color: AppColors.textMuted,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 100.ms),
                            const Spacer(),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          horizontalPadding, isSmall ? 16 : 24, horizontalPadding, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Step label
                          Text(
                            '— 03 / PAIEMENT',
                            style: AppTypography.caps(
                              size: 11,
                              letterSpacing: 2.4,
                              color: AppColors.accent,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1, end: 0, duration: 400.ms),

                          SizedBox(height: isSmall ? 8 : 12),

                          // Title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Confirmation',
                                style: AppTypography.display(
                                  size: size.width < 360 ? 28 : 32,
                                  weight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'de paiement',
                                  style: AppTypography.display(
                                    size: size.width < 360 ? 28 : 32,
                                    italic: true,
                                    weight: FontWeight.w300,
                                    letterSpacing: -1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 100.ms)
                              .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  delay: 100.ms,
                                  duration: 500.ms),

                          SizedBox(height: isSmall ? 20 : 28),

                          // ===== Summary card =====
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.surface,
                                  AppColors.softWarm.withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.ink.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 20 : 24,
                                horizontal: isSmall ? 14 : 20),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 28,
                                    child: _miniStat(
                                      label: 'DURÉE',
                                      child: Text(
                                        '${state.durationDays} jour${state.durationDays > 1 ? 's' : ''}',
                                        style: AppTypography.serif(
                                            size: isSmall ? 14 : 16,
                                            italic: true),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 8,
                                    child: Container(
                                      width: 1,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            AppColors.border,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 44,
                                    child: _miniStat(
                                      label: 'DATES',
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${_short(state.startDate)} → ${_short(state.endDate)}',
                                          style: AppTypography.body(
                                            size: isSmall ? 12 : 13,
                                            color: AppColors.ink,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 8,
                                    child: Container(
                                      width: 1,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            AppColors.border,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 28,
                                    child: _miniStat(
                                      label: 'TOTAL',
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${state.discountedTotal.toStringAsFixed(0)} DT',
                                          style: AppTypography.numeric(
                                            size: isSmall ? 18 : 20,
                                            weight: FontWeight.w900,
                                            color: AppColors.accent,
                                            letterSpacing: -0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 200.ms,
                                  duration: 500.ms)
                              .scale(
                                begin: const Offset(0.97, 0.97),
                                end: const Offset(1, 1),
                                delay: 200.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutBack,
                              ),

                          if (state.gameBonusCoins > 0) ...[
                            SizedBox(height: isSmall ? 12 : 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.coins,
                                      size: 18, color: AppColors.accent),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Bonus jeu: ${state.gameBonusCoins} DT',
                                      style: AppTypography.body(
                                        size: 14,
                                        weight: FontWeight.w700,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '-${state.gameBonusCoins} DT',
                                    style: AppTypography.numeric(
                                      size: 14,
                                      weight: FontWeight.w800,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 300.ms)
                                .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    delay: 300.ms,
                                    duration: 400.ms)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  delay: 300.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ],

                          SizedBox(height: isSmall ? 24 : 32),

                          // Method label
                          Text(
                            '— MÉTHODE',
                            style: AppTypography.caps(
                              size: 11,
                              letterSpacing: 2.4,
                              color: AppColors.textMuted,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 350.ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  delay: 350.ms,
                                  duration: 400.ms),

                          SizedBox(height: isSmall ? 10 : 12),

                          // ===== Payment method card =====
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1A1A2E),
                                  Color(0xFF16213E),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.ink.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(isSmall ? 16 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.gradientStart,
                                            AppColors.gradientEnd,
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        LucideIcons.creditCard,
                                        color: AppColors.surface,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CLICTOPAY',
                                            style: AppTypography.caps(
                                              size: 10,
                                              letterSpacing: 2,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Carte bancaire',
                                            style: AppTypography.body(
                                              size: 15,
                                              weight: FontWeight.w700,
                                              color: AppColors.surface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.gradientStart,
                                            AppColors.gradientEnd,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.check,
                                        color: AppColors.surface,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 16 : 20),
                                // Card number with glass effect
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.nfc,
                                        size: 20,
                                        color: AppColors.surface,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '•••• •••• •••• 4242',
                                            style: AppTypography.body(
                                              size: 16,
                                              weight: FontWeight.w600,
                                              color: AppColors.surface,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmall ? 10 : 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _darkField(
                                        label: 'EXPIRATION',
                                        value: '12/29',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _darkField(
                                        label: 'CVV',
                                        value: '•••',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 450.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 450.ms,
                                  duration: 600.ms)
                              .scale(
                                begin: const Offset(0.96, 0.96),
                                end: const Offset(1, 1),
                                delay: 450.ms,
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              ),

                          SizedBox(height: isSmall ? 16 : 24),

                          // ===== Security badge =====
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmall ? 12 : 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.softWarm,
                                  AppColors.softWarm
                                      .withValues(alpha: 0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    AppColors.accent.withValues(alpha: 0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    LucideIcons.shieldCheck,
                                    color: AppColors.surface,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CAUTION PRÉ-AUTORISÉE',
                                        style: AppTypography.caps(
                                          size: 10,
                                          letterSpacing: 1.8,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${PriceTag.format(deposit)} · non débitée',
                                        style: AppTypography.body(
                                          size: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 650.ms)
                              .slideY(
                                  begin: 0.15,
                                  end: 0,
                                  delay: 650.ms,
                                  duration: 500.ms),

                          // Bottom spacing so button doesn't overlap on scroll
                          SizedBox(height: isSmall ? 80 : 100),
                        ]),
                      ),
                    ),
                  ],
                ),

                // ===== Fixed bottom pay button =====
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 16,
                  child: PrimaryButton(
                    variant: ButtonVariant.gradient,
                    label: state.isProcessing
                        ? 'Traitement...'
                        : 'Payer ${state.discountedTotal.toStringAsFixed(0)} DT',
                    icon: state.isProcessing ? null : LucideIcons.lock,
                    loading: state.isProcessing,
                    onPressed: state.isProcessing
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            await context
                                .read<BookingCubit>()
                                .confirmBooking();
                            if (context.mounted) {
                              context.go('/booking/$carId/success');
                            }
                          },
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms)
                      .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 800.ms,
                          duration: 500.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        delay: 800.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _darkField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caps(
            size: 9,
            letterSpacing: 1.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            value,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.surface,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
