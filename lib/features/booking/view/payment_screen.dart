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
                          // Step label — clearer hierarchy with proximity grouping
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '03',
                                    style: AppTypography.body(
                                      size: 12,
                                      weight: FontWeight.w800,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Paiement',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
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
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.ink.withValues(alpha: 0.035),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: isSmall ? 22 : 26,
                                horizontal: isSmall ? 16 : 24),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 26,
                                    child: _miniStat(
                                      label: 'Durée',
                                      child: Text(
                                        '${state.durationDays} jour${state.durationDays > 1 ? 's' : ''}',
                                        style: AppTypography.body(
                                          size: isSmall ? 15 : 16,
                                          weight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Subtle vertical divider
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 48,
                                    child: _miniStat(
                                      label: 'Dates',
                                      child: Text(
                                        '${_short(state.startDate)} → ${_short(state.endDate)}',
                                        style: AppTypography.body(
                                          size: isSmall ? 13 : 14,
                                          weight: FontWeight.w600,
                                          color: AppColors.ink,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 26,
                                    child: _miniStat(
                                      label: 'Total',
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
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(
                                  begin: 0.15,
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
                                  const Icon(LucideIcons.coins,
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

                          // Method label — icon + text for instant recognition
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.creditCard,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Méthode de paiement',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
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
                          // Softer dark surface that still pops but doesn't shock the eye
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF23283A),
                                  Color(0xFF1A1F2E),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.ink.withValues(alpha: 0.10),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(isSmall ? 18 : 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: provider + selected badge
                                Row(
                                  children: [
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
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        LucideIcons.creditCard,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Clictopay',
                                            style: AppTypography.body(
                                              size: 11,
                                              weight: FontWeight.w600,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Carte bancaire',
                                            style: AppTypography.body(
                                              size: 16,
                                              weight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
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
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmall ? 18 : 22),
                                // Card number — grouped for readability (Gestalt proximity)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.nfc,
                                        size: 20,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '•••• •••• •••• 4242',
                                          style: AppTypography.body(
                                            size: 15,
                                            weight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmall ? 12 : 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _darkField(
                                        label: 'Expiration',
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
                                  begin: 0.15,
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
                            padding: EdgeInsets.all(isSmall ? 16 : 20),
                            decoration: BoxDecoration(
                              color: AppColors.softWarm,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.accent.withValues(alpha: 0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    LucideIcons.shieldCheck,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Caution pré-autorisée',
                                        style: AppTypography.body(
                                          size: 12,
                                          weight: FontWeight.w700,
                                          color: AppColors.accent,
                                          letterSpacing: 0.2,
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
                                  begin: 0.1,
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.body(
              size: 10,
              weight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
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
          style: AppTypography.body(
            size: 10,
            weight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            value,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
