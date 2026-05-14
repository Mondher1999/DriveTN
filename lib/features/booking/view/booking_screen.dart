import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../bloc/booking_state.dart';

class BookingScreen extends StatefulWidget {
  final String carId;
  const BookingScreen({super.key, required this.carId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  static const _totalSteps = 2; // 0 = extras, 1 = recap (dates removed)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<BookingCubit>();
      // Only init if not already pre-initialized from car detail flow
      if (cubit.state.car == null) {
        final car = MockData.carById(widget.carId);
        if (car != null) {
          cubit.initForCar(car);
        }
      }
    });
  }

  bool _canAdvance(BookingState state) {
    switch (_step) {
      case 0:
        return true; // extras — always can advance
      case 1:
        return true; // recap
      default:
        return true;
    }
  }

  void _next() =>
      setState(() => _step = (_step + 1).clamp(0, _totalSteps - 1));
  void _prev() {
    if (_step > 0) {
      setState(() => _step -= 1);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              const _BookingFloatingOrb(),
              SafeArea(
                child: Column(
                  children: [
                    _topBar(context, state),
                    _progress(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _stepContent(context, state),
                        ),
                      ),
                    ),
                    _bottomBar(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- top bar ---
  Widget _topBar(BuildContext context, BookingState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prev,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  size: 18, color: AppColors.ink),
            ),
          ),
          const Spacer(),
          Text(
            '${_step + 1} / $_totalSteps',
            style: AppTypography.caps(
              size: 11,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // --- progress bar ---
  Widget _progress() {
    final pct = (_step + 1) / _totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: AppColors.border),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                widthFactor: pct,
                heightFactor: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientEnd,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- step content ---
  Widget _stepContent(BuildContext context, BookingState state) {
    switch (_step) {
      case 0:
        return _stepExtras(context, state);
      case 1:
        return _stepRecap(context, state);
      default:
        return _stepExtras(context, state);
    }
  }

  // --- Step 1: Extras ---
  Widget _stepExtras(BuildContext context, BookingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— ÉTAPE 1 / 2',
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Vos',
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w900,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'extras ?',
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w300,
                  italic: true,
                  letterSpacing: -1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Personnalisez votre expérience.',
            style: AppTypography.body(size: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _extraTile(
            selected: state.additionalDriver,
            icon: LucideIcons.userPlus,
            title: 'Conducteur additionnel',
            caption: 'Ajoutez un autre conducteur',
            pricePerDay: 20,
            onTap: () {
              HapticFeedback.lightImpact();
              context
                  .read<BookingCubit>()
                  .toggleAdditionalDriver(!state.additionalDriver);
            },
          ),
          const SizedBox(height: 10),
          _extraTile(
            selected: state.babySeat,
            icon: LucideIcons.baby,
            title: 'Siège bébé',
            caption: 'Pour vos plus petits',
            pricePerDay: 10,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<BookingCubit>().toggleBabySeat(!state.babySeat);
            },
          ),
          const SizedBox(height: 10),
          _extraTile(
            selected: state.unlimitedKm,
            icon: LucideIcons.gauge,
            title: 'Kilométrage illimité',
            caption: 'Roulez sans compter',
            pricePerDay: 30,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<BookingCubit>().toggleUnlimitedKm(!state.unlimitedKm);
            },
          ),
        ],
      ),
    );
  }

  Widget _extraTile({
    required bool selected,
    required IconData icon,
    required String title,
    required String caption,
    required double pricePerDay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    AppColors.softWarm,
                    AppColors.softWarm.withValues(alpha: 0.4),
                  ]
                : [
                    AppColors.surface,
                    AppColors.softWarm.withValues(alpha: 0.45),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.45)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.18)
                    : AppColors.softWarm,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.h2(
                      size: 16,
                      weight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    style: AppTypography.body(
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${pricePerDay.toInt()} DT/jour',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      )
                    : null,
                color: selected ? null : AppColors.softWarm,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? LucideIcons.check : LucideIcons.plus,
                size: 14,
                color: selected ? AppColors.surface : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Recap ---
  Widget _stepRecap(BuildContext context, BookingState state) {
    if (state.car == null) return const SizedBox.shrink();
    final car = state.car!;
    final fmt = DateFormat('d MMM', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— ÉTAPE 2 / 2',
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Tout',
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w900,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'récapitulé.',
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w300,
                  italic: true,
                  letterSpacing: -1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Vehicle card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: car.photoUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: car.photoUrls.first,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              LucideIcons.car,
                              size: 28,
                              color: AppColors.textMuted,
                            ),
                          )
                        : const Icon(LucideIcons.car,
                            size: 28, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        car.brand.toUpperCase(),
                        style: AppTypography.caps(
                          size: 9,
                          letterSpacing: 1.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        car.model,
                        style:
                            AppTypography.h2(size: 18, weight: FontWeight.w800),
                      ),
                      Text(
                        car.plate,
                        style: AppTypography.body(
                          size: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dates
          _recapRow(
            icon: LucideIcons.calendar,
            label: 'PÉRIODE',
            value:
                '${fmt.format(state.startDate)} → ${fmt.format(state.endDate)}',
            subValue:
                '${state.durationDays} jour${state.durationDays > 1 ? 's' : ''}',
          ),
          if (state.additionalDriver ||
              state.babySeat ||
              state.unlimitedKm) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.softWarm,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.sparkles,
                            size: 14, color: AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EXTRAS',
                        style: AppTypography.caps(
                          size: 9,
                          letterSpacing: 1.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (state.additionalDriver)
                    _extraRecap('Conducteur additionnel',
                        '+${20 * state.durationDays} DT'),
                  if (state.babySeat)
                    _extraRecap(
                        'Siège bébé', '+${10 * state.durationDays} DT'),
                  if (state.unlimitedKm)
                    _extraRecap('Kilométrage illimité',
                        '+${30 * state.durationDays} DT'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Total — softWarm card (button stays the gradient CTA focal point)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.softWarm,
                  AppColors.softWarm.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 2,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tout inclus, taxes comprises',
                      style: AppTypography.body(
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: state.total),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: AppTypography.numeric(
                          size: 40,
                          weight: FontWeight.w900,
                          color: AppColors.accent,
                          letterSpacing: -1.6,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DT',
                        style: AppTypography.caps(
                          size: 12,
                          letterSpacing: 1.4,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(period: 2800.ms))
              .shimmer(
                duration: 1500.ms,
                color: AppColors.surface.withValues(alpha: 0.3),
                delay: 800.ms,
              ),
        ],
      ),
    );
  }

  Widget _recapRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softWarm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          if (subValue != null)
            Text(
              subValue,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _extraRecap(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                size: 13,
                color: AppColors.ink,
                weight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  // --- bottom bar ---
  Widget _bottomBar(BuildContext context, BookingState state) {
    final isLast = _step == _totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: PrimaryButton(
        label: isLast ? 'Vers le paiement →' : 'Continuer',
        icon: LucideIcons.arrowRight,
        variant: ButtonVariant.gradient,
        onPressed: _canAdvance(state)
            ? () {
                HapticFeedback.lightImpact();
                if (isLast) {
                  context.push('/booking/${widget.carId}/identity');
                } else {
                  _next();
                }
              }
            : null,
      ),
    );
  }
}

class _BookingFloatingOrb extends StatefulWidget {
  const _BookingFloatingOrb();

  @override
  State<_BookingFloatingOrb> createState() => _BookingFloatingOrbState();
}

class _BookingFloatingOrbState extends State<_BookingFloatingOrb>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -120 + (t * 60),
                right: -100 + (t * 40),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gradientStart.withValues(alpha: 0.18),
                        AppColors.gradientEnd.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -160 + ((1 - t) * 80),
                left: -120 + ((1 - t) * 50),
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gradientEnd.withValues(alpha: 0.18),
                        AppColors.gradientStart.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
