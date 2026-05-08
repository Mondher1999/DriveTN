import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '— PAIEMENT',
          style: AppTypography.label(
            size: 11,
            letterSpacing: 2.4,
            color: AppColors.textMuted,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final car = state.car;
          final deposit = car?.depositAmount ?? 0;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    Text(
                      '— 03 / PAIEMENT',
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 2.4,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Confirmation',
                      style: AppTypography.display(
                        size: 32,
                        italic: true,
                        weight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Récap mini stats
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _miniStat(
                                label: 'DURÉE',
                                child: Text(
                                  '${state.durationDays} jour${state.durationDays > 1 ? 's' : ''}',
                                  style: AppTypography.serif(
                                      size: 16, italic: true),
                                ),
                              ),
                            ),
                            Container(
                                width: 1, color: AppColors.border),
                            Expanded(
                              child: _miniStat(
                                label: 'DATES',
                                child: Text(
                                  '${_short(state.startDate)} → ${_short(state.endDate)}',
                                  style: AppTypography.body(
                                    size: 13,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                width: 1, color: AppColors.border),
                            Expanded(
                              child: _miniStat(
                                label: 'TOTAL',
                                child: PriceTag(
                                  price: state.total,
                                  size: 18,
                                  perDay: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      '— MÉTHODE',
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 2.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.creditCard,
                              color: AppColors.surface,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CLICTOPAY',
                                  style: AppTypography.label(
                                    size: 11,
                                    letterSpacing: 2,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Carte bancaire',
                                  style:
                                      AppTypography.serif(size: 14, italic: true),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.ink,
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
                    ),

                    const SizedBox(height: 16),
                    _readonlyField(
                      label: 'NUMÉRO DE CARTE',
                      value: '•••• •••• •••• 4242',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _readonlyField(
                            label: 'EXPIRATION',
                            value: '12/29',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _readonlyField(
                            label: 'CVV',
                            value: '•••',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.shieldCheck,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CAUTION PRÉ-AUTORISÉE',
                                  style: AppTypography.label(
                                    size: 11,
                                    letterSpacing: 2,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: 6),
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
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: PrimaryButton(
                    variant: ButtonVariant.gradient,
                    label: 'Payer ${state.total.toStringAsFixed(0)} DT',
                    loading: state.isProcessing,
                    onPressed: () async {
                      await context.read<BookingCubit>().confirmBooking();
                      if (context.mounted) {
                        context.go('/booking/$carId/success');
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _miniStat({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
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

  Widget _readonlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 2,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w500,
              color: AppColors.ink,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
