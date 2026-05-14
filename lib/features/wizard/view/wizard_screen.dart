import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../home/bloc/cars_cubit.dart';
import '../bloc/wizard_cubit.dart';
import '../bloc/wizard_state.dart';

class WizardScreen extends StatelessWidget {
  const WizardScreen({super.key});

  void _finish(BuildContext context, WizardState state) {
    context.read<CarsCubit>().applyFilters(
          priceRange: state.budget,
          categories: state.matchedCategories,
          transmissions: state.matchedTransmissions,
          fuels: state.matchedFuels,
          minSeats: state.minSeats,
          maxSeats: state.maxSeats,
        );

    if (state.pickup != null) {
      final items = _pickupItems();
      final item = items.firstWhere(
        (i) => i.value == state.pickup,
        orElse: () => items.last,
      );
      context.read<CarsCubit>().setSearchLocation(item.label);
    }

    if (state.startDate != null && state.endDate != null) {
      context
          .read<CarsCubit>()
          .setSearchDates((state.startDate!, state.endDate!));
    }

    context.go('/home/explorer');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WizardCubit, WizardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              const _FloatingOrb(),
              SafeArea(
                child: Column(
                  children: [
                    _topBar(context, state),
                    _progress(state),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        layoutBuilder: (currentChild, previousChildren) =>
                            Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        ),
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
                          key: ValueKey(state.step),
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
  Widget _topBar(BuildContext context, WizardState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (state.step == 0) {
                context.go('/login');
              } else {
                context.read<WizardCubit>().prev();
              }
            },
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
            '${state.step + 1} / ${WizardState.totalSteps}',
            style: AppTypography.caps(
              size: 11,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.read<CarsCubit>().resetFilters();
              context.go('/home/explorer');
            },
            child: Text(
              'Passer',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- progress bar ---
  Widget _progress(WizardState state) {
    final pct = (state.step + 1) / WizardState.totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Stack(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: 3,
                width: pct * constraints.maxWidth,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- step router ---
  Widget _stepContent(BuildContext context, WizardState state) {
    switch (state.step) {
      case 0:
        return _stepUseCase(context, state);
      case 1:
        return _stepCarType(context, state);
      case 2:
        return _stepDates(context, state);
      case 3:
        return _stepBudget(context, state);
      case 4:
        return _stepFuel(context, state);
      case 5:
        return _stepSeats(context, state);
      case 6:
        return _stepTransmission(context, state);
      case 7:
        return _stepPickup(context, state);
      default:
        return _stepUseCase(context, state);
    }
  }

  // --- Step 1: Use case ---
  Widget _stepUseCase(BuildContext context, WizardState state) {
    final items = <(WizardUseCase, IconData, String, String, String?)>[
      (
        WizardUseCase.business,
        LucideIcons.briefcase,
        'Business',
        'Déplacements professionnels',
        null
      ),
      (
        WizardUseCase.tourism,
        LucideIcons.mapPin,
        'Tourisme',
        'Visites & vacances',
        'POPULAIRE'
      ),
      (
        WizardUseCase.event,
        LucideIcons.partyPopper,
        'Événement',
        'Mariage, fête, cérémonie',
        'TRENDING'
      ),
      (
        WizardUseCase.longTerm,
        LucideIcons.calendar,
        'Longue durée',
        'Location mensuelle',
        null
      ),
    ];
    return _stepLayout(
      label: '— ÉTAPE 1 / 8',
      title: 'Pour quoi',
      titleItalic: 'faire ?',
      subtitle: "Quel type d'expérience cherchez-vous ?",
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
        children: [
          for (final item in items)
            _premiumTile(
              selected: state.useCase == item.$1,
              icon: item.$2,
              title: item.$3,
              caption: item.$4,
              badge: item.$5,
              onTap: () async {
                HapticFeedback.lightImpact();
                context.read<WizardCubit>().setUseCase(item.$1);
                await Future.delayed(const Duration(milliseconds: 380));
                if (context.mounted) {
                  context.read<WizardCubit>().next();
                }
              },
            ),
        ],
      ),
    );
  }

  // --- Step 2: Car type ---
  Widget _stepCarType(BuildContext context, WizardState state) {
    final items = <(WizardCarType, IconData, String, String, String?)>[
      (
        WizardCarType.city,
        LucideIcons.car,
        'Citadine',
        'Compacte & agile',
        null
      ),
      (
        WizardCarType.sedan,
        LucideIcons.car,
        'Berline',
        'Confort & élégance',
        'POPULAIRE'
      ),
      (
        WizardCarType.suv,
        LucideIcons.mountain,
        'SUV',
        'Espace & robustesse',
        null
      ),
      (
        WizardCarType.fourByFour,
        LucideIcons.trees,
        '4x4',
        'Tout-terrain',
        null
      ),
      (
        WizardCarType.convertible,
        LucideIcons.wind,
        'Cabriolet',
        'Toit ouvert',
        null
      ),
      (WizardCarType.coupe, LucideIcons.zap, 'Coupé', 'Sport & design', null),
    ];
    return _stepLayout(
      label: '— ÉTAPE 2 / 8',
      title: 'Quel',
      titleItalic: 'type ?',
      subtitle: 'Le format qui correspond à votre besoin.',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
        children: [
          for (final item in items)
            _premiumTile(
              selected: state.carType == item.$1,
              icon: item.$2,
              title: item.$3,
              caption: item.$4,
              badge: item.$5,
              onTap: () async {
                HapticFeedback.lightImpact();
                context.read<WizardCubit>().setCarType(item.$1);
                await Future.delayed(const Duration(milliseconds: 380));
                if (context.mounted) context.read<WizardCubit>().next();
              },
            ),
        ],
      ),
    );
  }

  // --- Step 3: Dates ---
  Widget _stepDates(BuildContext context, WizardState state) {
    return _stepLayout(
      label: '— ÉTAPE 3 / 8',
      title: 'Quelles',
      titleItalic: 'dates ?',
      subtitle: 'Quand voulez-vous partir ?',
      child: _StepDatesPicker(state: state),
    );
  }

  // --- Step 4: Budget ---
  Widget _stepBudget(BuildContext context, WizardState state) {
    final presets = [
      (50.0, 150.0, 'Eco', LucideIcons.wallet, const Color(0xFF10B981)),
      (150.0, 400.0, 'Standard', LucideIcons.car, const Color(0xFF3B82F6)),
      (400.0, 700.0, 'Premium', LucideIcons.gem, const Color(0xFFF59E0B)),
      (700.0, 1000.0, 'Luxe', LucideIcons.crown, const Color(0xFF8B5CF6)),
    ];

    // Clamp budget to the slider's range to avoid assertion errors
    // when the state holds old values (e.g. from a previous session).
    final safeStart = state.budget.start.clamp(50.0, 1000.0);
    final safeEnd = state.budget.end.clamp(50.0, 1000.0);
    final safeBudget = RangeValues(
      safeStart <= safeEnd ? safeStart : safeEnd,
      safeStart <= safeEnd ? safeEnd : safeStart,
    );

    // Find matching preset for animation
    final selectedIndex = presets.indexWhere(
        (p) => safeBudget.start >= p.$1 - 1 && safeBudget.end <= p.$2 + 1);

    return _stepLayout(
      label: '— ÉTAPE 4 / 8',
      title: 'Votre',
      titleItalic: 'budget ?',
      subtitle: 'Sélectionnez une fourchette ou utilisez le slider.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal price range display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 50, end: safeBudget.start.round()),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => Text(
                  'Min — $value DT',
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 1000, end: safeBudget.end.round()),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => Text(
                  '$value DT — Max',
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 24),
          // Visual bar
          _buildBudgetBar(safeBudget),
          const SizedBox(height: 24),
          // RangeSlider — premium custom theme
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.border.withValues(alpha: 0.4),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 4,
                pressedElevation: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              overlayColor: AppColors.accent.withValues(alpha: 0.12),
              showValueIndicator: ShowValueIndicator.always,
              valueIndicatorColor: AppColors.ink,
              valueIndicatorTextStyle: AppTypography.body(
                size: 12,
                weight: FontWeight.w800,
                color: AppColors.surface,
              ),
            ),
            child: RangeSlider(
              values: safeBudget,
              min: 50,
              max: 1000,
              divisions: 95,
              labels: RangeLabels(
                '${safeBudget.start.round()} DT',
                '${safeBudget.end.round()} DT',
              ),
              onChanged: (v) {
                HapticFeedback.lightImpact();
                final clampedStart = v.start.clamp(50.0, 1000.0);
                final clampedEnd = v.end.clamp(50.0, 1000.0);
                context.read<WizardCubit>().setBudget(
                      RangeValues(
                        clampedStart <= clampedEnd ? clampedStart : clampedEnd,
                        clampedStart <= clampedEnd ? clampedEnd : clampedStart,
                      ),
                    );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Preset chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final p = presets[index];
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context
                        .read<WizardCubit>()
                        .setBudget(RangeValues(p.$1, p.$2));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [p.$5, p.$5.withValues(alpha: 0.8)],
                            )
                          : null,
                      color: isSelected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? Colors.transparent : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: p.$5.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.$4,
                            size: 14,
                            color: isSelected ? AppColors.surface : p.$5),
                        const SizedBox(width: 4),
                        Text(
                          p.$3,
                          style: AppTypography.body(
                            size: 11,
                            weight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color:
                                isSelected ? AppColors.surface : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (100 + index * 80).ms, duration: 350.ms)
                    .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: (100 + index * 80).ms,
                        duration: 350.ms);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Price distribution hint
          Center(
            child: Text(
              'Faites glisser les curseurs pour affiner',
              style: AppTypography.body(
                size: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBar(RangeValues budget) {
    final total = 1000.0 - 50.0;
    final leftPct = ((budget.start - 50) / total).clamp(0.0, 1.0);
    final widthPct = ((budget.end - budget.start) / total).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        return Container(
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: leftPct * barWidth,
                top: 0,
                bottom: 0,
                width: widthPct * barWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Step 5: Fuel ---
  Widget _stepFuel(BuildContext context, WizardState state) {
    final items = <(WizardFuel, IconData, String, String)>[
      (WizardFuel.gasoline, LucideIcons.fuel, 'Essence', 'Le plus courant'),
      (WizardFuel.diesel, LucideIcons.fuel, 'Diesel', 'Autonomie & couple'),
      (WizardFuel.hybrid, LucideIcons.leaf, 'Hybride', 'Économique & propre'),
      (
        WizardFuel.any,
        LucideIcons.settings2,
        'Peu importe',
        'Tous les carburants'
      ),
    ];
    return _stepLayout(
      label: '— ÉTAPE 5 / 8',
      title: 'Quel',
      titleItalic: 'carburant ?',
      subtitle: 'Votre préférence énergétique.',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          for (final item in items)
            _premiumTile(
              selected: state.fuel == item.$1,
              icon: item.$2,
              title: item.$3,
              caption: item.$4,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<WizardCubit>().setFuel(item.$1);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) context.read<WizardCubit>().next();
                });
              },
            ),
        ],
      ),
    );
  }

  // --- Step 6: Seats ---
  Widget _stepSeats(BuildContext context, WizardState state) {
    final items = <(WizardSeats, IconData, String, String)>[
      (WizardSeats.small, LucideIcons.user, 'Petite', '2-4 places'),
      (WizardSeats.medium, LucideIcons.users, 'Moyenne', '5 Places'),
      (WizardSeats.large, LucideIcons.userPlus, 'Grande', '7+ places'),
    ];
    return _stepLayout(
      label: '— ÉTAPE 6 / 8',
      title: 'Combien',
      titleItalic: 'de places ?',
      subtitle: 'Pour vous et votre équipage.',
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              // ✅ After
              child: _premiumWideTile(
                selected: state.seats == item.$1,
                icon: item.$2,
                title: item.$3,
                caption: item.$4,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  context.read<WizardCubit>().setSeats(item.$1);
                  await Future.delayed(const Duration(milliseconds: 380));
                  if (context.mounted) {
                    context.read<WizardCubit>().next();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  // --- Step 7: Transmission ---
  Widget _stepTransmission(BuildContext context, WizardState state) {
    final items = <(WizardTransmission, IconData, String, String)>[
      (
        WizardTransmission.automatic,
        LucideIcons.cog,
        'Automatique',
        'Confort & simplicité'
      ),
      (
        WizardTransmission.manual,
        LucideIcons.wrench,
        'Manuelle',
        'Contrôle & sensation'
      ),
      (
        WizardTransmission.any,
        LucideIcons.settings2,
        'Peu importe',
        'Toutes les boîtes'
      ),
    ];
    return _stepLayout(
      label: '— ÉTAPE 7 / 8',
      title: 'Quelle',
      titleItalic: 'boîte ?',
      subtitle: 'Boîte automatique ou manuelle ?',
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _premiumWideTile(
                selected: state.transmission == item.$1,
                icon: item.$2,
                title: item.$3,
                caption: item.$4,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  context.read<WizardCubit>().setTransmission(item.$1);
                  await Future.delayed(const Duration(milliseconds: 380));
                  if (context.mounted) context.read<WizardCubit>().next();
                },
              ),
            ),
        ],
      ),
    );
  }

  // --- Step 8: Pickup ---
  Widget _stepPickup(BuildContext context, WizardState state) {
    final items = _pickupItems();
    return _stepLayout(
      label: '— ÉTAPE 8 / 8',
      title: 'Lieu de',
      titleItalic: 'prise en charge ?',
      subtitle: 'Le quartier où récupérer (et restituer) la voiture.',
      child: _PickupDropdown(
        value: state.pickup,
        items: items,
        onChanged: (v) async {
          HapticFeedback.mediumImpact();
          context.read<WizardCubit>().setPickup(v);
          await Future.delayed(const Duration(milliseconds: 420));
          if (context.mounted) {
            _finish(context, context.read<WizardCubit>().state);
          }
        },
      ),
    );
  }

  Widget _premiumWideTile({
    required bool selected,
    required IconData icon,
    required String title,
    required String caption,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.softWarm.withValues(alpha: 0.45),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Colors.transparent : AppColors.border,
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.surface.withValues(alpha: 0.22)
                        : AppColors.softWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: selected ? AppColors.surface : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTypography.h2(
                              size: 17,
                              weight: FontWeight.w800,
                              color:
                                  selected ? AppColors.surface : AppColors.ink,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.surface.withValues(alpha: 0.22)
                                    : AppColors.ink,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge,
                                style: AppTypography.caps(
                                  size: 8,
                                  letterSpacing: 1.2,
                                  color: AppColors.surface,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caption,
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w500,
                          color: selected
                              ? AppColors.surface.withValues(alpha: 0.85)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.surface : AppColors.softWarm,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? LucideIcons.check : LucideIcons.arrowRight,
                    size: 14,
                    color: selected ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned.fill(
              child: _sparkles(keyForTrigger: ValueKey('${title}_$selected')),
            ),
        ],
      ),
    );
  }

  // --- step layout helper ---
  Widget _stepLayout({
    required String label,
    required String title,
    required String titleItalic,
    required String subtitle,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              Text(
                label,
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 3,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: AppTypography.display(
                    size: 36,
                    weight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                  children: [
                    TextSpan(text: title),
                    const WidgetSpan(child: SizedBox(width: 8)),
                    TextSpan(
                      text: titleItalic,
                      style: AppTypography.display(
                        size: 36,
                        weight: FontWeight.w300,
                        italic: true,
                        letterSpacing: -1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTypography.body(
                  size: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        );
      },
    );
  }

  // --- premium selection tile ---
  Widget _premiumTile({
    required bool selected,
    required IconData icon,
    required String title,
    required String caption,
    String? badge,
    required VoidCallback onTap,
    bool centerContent = false,
    bool horizontal = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.softWarm.withValues(alpha: 0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: horizontal
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : const EdgeInsets.all(16),
        child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.surface : AppColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.h2(
                            size: 15,
                            weight: FontWeight.w800,
                            color: selected ? AppColors.surface : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          caption,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w500,
                            color: selected
                                ? AppColors.surface.withValues(alpha: 0.85)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: centerContent
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: centerContent
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected ? AppColors.surface : AppColors.accent,
                      ),
                      if (!centerContent) ...[
                        const Spacer(),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.surface.withValues(alpha: 0.22)
                                  : AppColors.ink,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge,
                              style: AppTypography.caps(
                                size: 8,
                                letterSpacing: 1.2,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    textAlign:
                        centerContent ? TextAlign.center : TextAlign.start,
                    style: AppTypography.h2(
                      size: 15,
                      weight: FontWeight.w800,
                      color: selected ? AppColors.surface : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
                    textAlign:
                        centerContent ? TextAlign.center : TextAlign.start,
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w500,
                      color: selected
                          ? AppColors.surface.withValues(alpha: 0.85)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- sparkle decoration ---
  Widget _sparkles({required Key keyForTrigger}) {
    return Container();
  }

  // --- bottom bar (floating CTA) ---
  Widget _bottomBar(BuildContext context, WizardState state) {
    final bool isDatesStep = state.step == 2;
    final bool onStartTab = isDatesStep && state.isStartTab;
    final bool isLastStep = state.step == WizardState.totalSteps - 1;
    final bool showButton = isDatesStep || state.step == 3;

    if (!showButton) return const SizedBox.shrink();

    final bool canTap = isDatesStep
        ? (onStartTab ? state.startDate != null : state.canAdvance)
        : (isLastStep ? state.pickup != null : state.canAdvance);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 240),
          opacity: canTap ? 1 : 0.4,
          child: GestureDetector(
            onTap: canTap
                ? () {
                    HapticFeedback.lightImpact();
                    if (onStartTab) {
                      context.read<WizardCubit>().setStartTab(false);
                    } else if (isLastStep) {
                      _finish(context, state);
                    } else {
                      context.read<WizardCubit>().next();
                    }
                  }
                : null,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: canTap
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 2),
                  Text(
                    onStartTab
                        ? 'Choisir la date de fin'
                        : isLastStep
                            ? 'Voir les résultats'
                            : 'Continuer',
                    style: AppTypography.body(
                      size: 15,
                      weight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: canTap ? (c) => c.repeat(reverse: true) : null)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.03, 1.03),
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      ),
    );
  }

  List<_PickupItem> _pickupItems() => const [
        _PickupItem(WizardPickup.aeroportTunisCarthage, LucideIcons.plane,
            'Aéroport Tunis-Carthage (TUN)'),
        _PickupItem(WizardPickup.aeroportDjerbaZarzis, LucideIcons.plane,
            'Aéroport Djerba-Zarzis (DJE)'),
        _PickupItem(WizardPickup.aeroportMonastir, LucideIcons.plane,
            'Aéroport Monastir (MIR)'),
        _PickupItem(WizardPickup.aeroportSfax, LucideIcons.plane,
            'Aéroport Sfax (SFA)'),
        _PickupItem(WizardPickup.djerba, LucideIcons.palmtree, 'Djerba'),
        _PickupItem(WizardPickup.djerbaHoumetSouk, LucideIcons.palmtree,
            'Djerba-Houmet Souk'),
        _PickupItem(
            WizardPickup.djerbaMidoun, LucideIcons.palmtree, 'Djerba-Midoun'),
        _PickupItem(WizardPickup.djerbaZoneTouristique, LucideIcons.palmtree,
            'Djerba-Zone Touristique'),
        _PickupItem(WizardPickup.hammamet, LucideIcons.umbrella, 'Hammamet'),
        _PickupItem(WizardPickup.mahdia, LucideIcons.landmark, 'Mahdia'),
        _PickupItem(WizardPickup.monastir, LucideIcons.landmark, 'Monastir'),
        _PickupItem(WizardPickup.sfax, LucideIcons.building, 'Sfax'),
        _PickupItem(WizardPickup.sousse, LucideIcons.building, 'Sousse'),
        _PickupItem(WizardPickup.tunis, LucideIcons.building, 'Tunis'),
        _PickupItem(
            WizardPickup.tunisCentre, LucideIcons.building, 'Tunis Centre'),
        _PickupItem(WizardPickup.laMarsa, LucideIcons.waves, 'La Marsa'),
        _PickupItem(WizardPickup.lac1, LucideIcons.briefcase, 'Lac 1'),
        _PickupItem(WizardPickup.lac2, LucideIcons.building2, 'Lac 2'),
        _PickupItem(WizardPickup.ariana, LucideIcons.home, 'Ariana'),
        _PickupItem(WizardPickup.soukra, LucideIcons.trees, 'Soukra'),
        _PickupItem(WizardPickup.carthage, LucideIcons.landmark, 'Carthage'),
        _PickupItem(WizardPickup.any, LucideIcons.shuffle, 'Peu importe'),
      ];
} // ← closes WizardScreen

// ── helper classes live outside WizardScreen ──────────────────────────────

class _PickupItem {
  final WizardPickup value;
  final IconData icon;
  final String label;
  const _PickupItem(this.value, this.icon, this.label);
}
// ---------------------------------------------------------------------------
// Pickup dropdown helpers
// ---------------------------------------------------------------------------

class _PickupDropdown extends StatefulWidget {
  final WizardPickup? value;
  final List<_PickupItem> items;
  final ValueChanged<WizardPickup> onChanged;

  const _PickupDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_PickupDropdown> createState() => _PickupDropdownState();
}

class _PickupDropdownState extends State<_PickupDropdown> {
  bool _open = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_PickupItem> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where((i) => i.label.toLowerCase().contains(q))
        .toList();
  }

  String get _selectedLabel {
    final found = widget.items.firstWhere(
      (i) => i.value == widget.value,
      orElse: () => widget.items.last,
    );
    return found.label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row
        Row(
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              'Lieu de prise',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Dropdown trigger / expanded panel
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _open = !_open);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trigger bar (always visible)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedLabel,
                          style: AppTypography.h2(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 260),
                        child: const Icon(
                          LucideIcons.chevronDown,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded list
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1, color: AppColors.border),
                      // Search field

                      const Divider(height: 1, color: AppColors.border),
                      // Options list
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final item = _filtered[index];
                              final selected = widget.value == item.value;
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _open = false);
                                  widget.onChanged(item.value);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? const LinearGradient(
                                            colors: [
                                              AppColors.gradientStart,
                                              AppColors.gradientEnd,
                                            ],
                                          )
                                        : null,
                                    color: selected ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color: selected
                                            ? AppColors.surface
                                            : AppColors.accent,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: AppTypography.body(
                                            size: 14,
                                            weight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: selected
                                                ? AppColors.surface
                                                : AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          LucideIcons.check,
                                          size: 16,
                                          color: AppColors.surface,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                  crossFadeState: _open
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 260),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inline date picker (Step 3)
// ---------------------------------------------------------------------------

class _StepDatesPicker extends StatefulWidget {
  final WizardState state;
  const _StepDatesPicker({required this.state});

  @override
  State<_StepDatesPicker> createState() => _StepDatesPickerState();
}

class _StepDatesPickerState extends State<_StepDatesPicker> {
  void _onDateTimeChanged(DateTime date) {
    if (widget.state.isStartTab) {
      context.read<WizardCubit>().setStartDate(date);
    } else {
      context.read<WizardCubit>().setEndDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = widget.state.startDate ?? today;
    final end = widget.state.endDate ?? start.add(const Duration(days: 1));
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final fmtTime = DateFormat('HH:mm', 'fr_FR');

    final isStart = widget.state.isStartTab;
    final pickerDate = isStart ? start : end;
    final minDate =
        isStart ? DateTime(today.year, today.month, today.day) : start;
    final maxDate = today.add(const Duration(days: 90));
    final hasBoth =
        widget.state.startDate != null && widget.state.endDate != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Début / Fin pills — glassmorphism style
        Row(
          children: [
            Expanded(
              child: _DatePill(
                label: 'Début',
                dateText: widget.state.startDate != null
                    ? fmt.format(widget.state.startDate!)
                    : 'Choisir',
                timeText: widget.state.startDate != null
                    ? fmtTime.format(widget.state.startDate!)
                    : '--:--',
                selected: isStart,
                onTap: () => context.read<WizardCubit>().setStartTab(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePill(
                label: 'Fin',
                dateText: widget.state.endDate != null
                    ? fmt.format(widget.state.endDate!)
                    : 'Choisir',
                timeText: widget.state.endDate != null
                    ? fmtTime.format(widget.state.endDate!)
                    : '--:--',
                selected: !isStart,
                needsAttention: isStart && widget.state.startDate != null,
                onTap: () => context.read<WizardCubit>().setStartTab(false),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 20),
        // Cupertino wheel picker — premium container
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.state.isStartTab
                  ? AppColors.accent.withValues(alpha: 0.25)
                  : AppColors.border,
              width: widget.state.isStartTab ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              if (widget.state.isStartTab)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Theme(
              data: Theme.of(context).copyWith(
                cupertinoOverrideTheme: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: AppTypography.body(
                      size: 20,
                      weight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                key: ValueKey(widget.state.isStartTab ? 'start' : 'end'),
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: pickerDate,
                minimumDate: minDate,
                maximumDate: maxDate,
                onDateTimeChanged: _onDateTimeChanged,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: 100.ms),
        // Duration badge — glassmorphism
        if (hasBoth) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.softWarm,
                  AppColors.softWarm.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.clock,
                    size: 16,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DURÉE DE LOCATION',
                      style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.state.durationDays} jour${widget.state.durationDays > 1 ? 's' : ''}',
                      style: AppTypography.numeric(
                        size: 20,
                        weight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Mini calendar visual
                _miniCalendar(widget.state.startDate!, widget.state.endDate!),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),
        ] else ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendarClock,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  'Sélectionnez les deux dates',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ],
    );
  }

  Widget _miniCalendar(DateTime start, DateTime end) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _calBox(start.day.toString(), DateFormat('MMM', 'fr_FR').format(start)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        _calBox(end.day.toString(), DateFormat('MMM', 'fr_FR').format(end)),
      ],
    );
  }

  Widget _calBox(String day, String month) {
    return Container(
      width: 42,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month.toUpperCase(),
            style: AppTypography.caps(
              size: 7,
              letterSpacing: 1,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            day,
            style: AppTypography.numeric(
              size: 16,
              weight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;
  final String dateText;
  final String timeText;
  final bool selected;
  final bool needsAttention;
  final VoidCallback onTap;

  const _DatePill({
    required this.label,
    required this.dateText,
    this.timeText = '',
    required this.selected,
    this.needsAttention = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientStart,
                  AppColors.gradientEnd,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.softWarm.withValues(alpha: 0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : needsAttention
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : AppColors.border,
          width: selected ? 0 : (needsAttention ? 1.5 : 1),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : needsAttention
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.caps(
                  size: 9,
                  letterSpacing: 1.8,
                  color: selected
                      ? AppColors.surface.withValues(alpha: 0.9)
                      : needsAttention
                          ? AppColors.accent
                          : AppColors.textMuted,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.surface.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 1000.ms, curve: Curves.easeInOut),
              ],
              if (needsAttention && !selected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.2, 1.2),
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: AppTypography.h2(
              size: 15,
              weight: FontWeight.w800,
              color: selected ? AppColors.surface : AppColors.ink,
            ),
          ),
          if (timeText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              timeText,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w600,
                color: selected
                    ? AppColors.surface.withValues(alpha: 0.85)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: needsAttention && !selected
          ? pill.animate().shimmer(
              duration: 1200.ms, color: AppColors.accent.withValues(alpha: 0.1))
          : pill,
    );
  }
}

class _FloatingOrb extends StatefulWidget {
  const _FloatingOrb();

  @override
  State<_FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<_FloatingOrb>
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
