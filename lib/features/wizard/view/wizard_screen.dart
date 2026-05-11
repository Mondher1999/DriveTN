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
      context.read<CarsCubit>().setSearchDates((state.startDate!, state.endDate!));
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
      (WizardUseCase.business, LucideIcons.briefcase, 'Business', 'Déplacements professionnels', null),
      (WizardUseCase.tourism, LucideIcons.mapPin, 'Tourisme', 'Visites & vacances', 'POPULAIRE'),
      (WizardUseCase.event, LucideIcons.partyPopper, 'Événement', 'Mariage, fête, cérémonie', 'TRENDING'),
      (WizardUseCase.longTerm, LucideIcons.calendar, 'Longue durée', 'Location mensuelle', null),
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
      (WizardCarType.city, LucideIcons.car, 'Citadine', 'Compacte & agile', null),
      (WizardCarType.sedan, LucideIcons.car, 'Berline', 'Confort & élégance', 'POPULAIRE'),
      (WizardCarType.suv, LucideIcons.mountain, 'SUV', 'Espace & robustesse', null),
      (WizardCarType.fourByFour, LucideIcons.trees, '4x4', 'Tout-terrain', null),
      (WizardCarType.convertible, LucideIcons.wind, 'Cabriolet', 'Toit ouvert', null),
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
    return _stepLayout(
      label: '— ÉTAPE 4 / 8',
      title: 'Quel',
      titleItalic: 'budget ?',
      subtitle: 'Faites glisser pour ajuster.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Big numeric range
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                state.budget.start.toInt().toString(),
                style: AppTypography.numeric(
                  size: 56,
                  weight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: -2,
                ),
              ),
              Text(
                ' — ',
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w300,
                  italic: true,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                state.budget.end.toInt().toString(),
                style: AppTypography.numeric(
                  size: 56,
                  weight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'DT par jour',
            style: AppTypography.caps(
              size: 11,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.ink,
              overlayColor: AppColors.accent.withValues(alpha: 0.1),
              rangeThumbShape:
                  const RoundRangeSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: state.budget,
              min: 50,
              max: 2000,
              divisions: 39,
              onChanged: (v) =>
                  context.read<WizardCubit>().setBudget(v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Éco · 50',
                  style: AppTypography.caps(
                    size: 10,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Premium · 2000',
                  style: AppTypography.caps(
                    size: 10,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 5: Fuel ---
  Widget _stepFuel(BuildContext context, WizardState state) {
    final items = <(WizardFuel, IconData, String, String, String?)>[
      (WizardFuel.gasoline, LucideIcons.fuel, 'Essence', 'Performance', null),
      (WizardFuel.diesel, LucideIcons.droplet, 'Diesel', 'Économique', null),
      (WizardFuel.hybrid, LucideIcons.leaf, 'Hybride', 'Le meilleur des deux', 'ÉCO'),
      (WizardFuel.any, LucideIcons.shuffle, 'Peu importe', 'Toutes options', null),
    ];
    return _stepLayout(
      label: '— ÉTAPE 5 / 8',
      title: 'Quel',
      titleItalic: 'carburant ?',
      subtitle: 'Pour matcher vos préférences à la pompe.',
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
              selected: state.fuel == item.$1,
              icon: item.$2,
              title: item.$3,
              caption: item.$4,
              badge: item.$5,
              onTap: () async {
                HapticFeedback.lightImpact();
                context.read<WizardCubit>().setFuel(item.$1);
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

  // --- Step 6: Seats ---
  Widget _stepSeats(BuildContext context, WizardState state) {
    final items = <(WizardSeats, IconData, String, String, String?)>[
      (WizardSeats.small, LucideIcons.user, 'Petit', '2-4 places', null),
      (WizardSeats.medium, LucideIcons.users, 'Standard', '5 places', 'POPULAIRE'),
      (WizardSeats.large, LucideIcons.users, 'Grand', '7+ places', null),
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
              child: _premiumWideTile(
                selected: state.seats == item.$1,
                icon: item.$2,
                title: item.$3,
                caption: item.$4,
                badge: item.$5,
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
    final items = <(WizardTransmission, IconData, String, String, String?)>[
      (WizardTransmission.automatic, LucideIcons.zap, 'Automatique', 'Confort total', 'POPULAIRE'),
      (WizardTransmission.manual, LucideIcons.cog, 'Manuelle', 'Plus économique', null),
      (WizardTransmission.any, LucideIcons.shuffle, 'Peu importe', 'Toutes options', null),
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
                badge: item.$5,
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

  List<_PickupItem> _pickupItems() => const [
    _PickupItem(WizardPickup.aeroportTunisCarthage, LucideIcons.plane, 'Aéroport Tunis-Carthage (TUN)'),
    _PickupItem(WizardPickup.aeroportDjerbaZarzis, LucideIcons.plane, 'Aéroport Djerba-Zarzis (DJE)'),
    _PickupItem(WizardPickup.aeroportMonastir, LucideIcons.plane, 'Aéroport Monastir (MIR)'),
    _PickupItem(WizardPickup.aeroportSfax, LucideIcons.plane, 'Aéroport Sfax (SFA)'),
    _PickupItem(WizardPickup.djerba, LucideIcons.palmtree, 'Djerba'),
    _PickupItem(WizardPickup.djerbaHoumetSouk, LucideIcons.palmtree, 'Djerba-Houmet Souk'),
    _PickupItem(WizardPickup.djerbaMidoun, LucideIcons.palmtree, 'Djerba-Midoun'),
    _PickupItem(WizardPickup.djerbaZoneTouristique, LucideIcons.palmtree, 'Djerba-Zone Touristique'),
    _PickupItem(WizardPickup.hammamet, LucideIcons.umbrella, 'Hammamet'),
    _PickupItem(WizardPickup.mahdia, LucideIcons.landmark, 'Mahdia'),
    _PickupItem(WizardPickup.monastir, LucideIcons.landmark, 'Monastir'),
    _PickupItem(WizardPickup.sfax, LucideIcons.building, 'Sfax'),
    _PickupItem(WizardPickup.sousse, LucideIcons.building, 'Sousse'),
    _PickupItem(WizardPickup.tunis, LucideIcons.building, 'Tunis'),
    _PickupItem(WizardPickup.tunisCentre, LucideIcons.building, 'Tunis Centre'),
    _PickupItem(WizardPickup.laMarsa, LucideIcons.waves, 'La Marsa'),
    _PickupItem(WizardPickup.lac1, LucideIcons.briefcase, 'Lac 1'),
    _PickupItem(WizardPickup.lac2, LucideIcons.building2, 'Lac 2'),
    _PickupItem(WizardPickup.ariana, LucideIcons.home, 'Ariana'),
    _PickupItem(WizardPickup.soukra, LucideIcons.trees, 'Soukra'),
    _PickupItem(WizardPickup.carthage, LucideIcons.landmark, 'Carthage'),
    _PickupItem(WizardPickup.any, LucideIcons.shuffle, 'Peu importe'),
  ];

  // --- shared layout for steps ---
  Widget _stepLayout({
    required String label,
    required String title,
    required String titleItalic,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  // --- tiles ---
  Widget _premiumTile({
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.surface.withValues(alpha: 0.22)
                        : AppColors.softWarm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.surface : AppColors.accent,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h2(
                        size: 16,
                        weight: FontWeight.w800,
                        color: selected ? AppColors.surface : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: AppTypography.body(
                        size: 11,
                        weight: FontWeight.w500,
                        color: selected
                            ? AppColors.surface.withValues(alpha: 0.85)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (badge != null && !selected)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.ink,
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
            ),
          if (selected)
            Positioned.fill(
              child: _sparkles(keyForTrigger: ValueKey('${title}_$selected')),
            ),
        ],
      ),
    );
  }

  Widget _sparkles({required Key keyForTrigger}) {
    const positions = [
      Offset(8, -4),
      Offset(-6, 12),
      Offset(50, -8),
      Offset(70, 30),
      Offset(-4, 50),
      Offset(80, 80),
    ];
    return IgnorePointer(
      child: Stack(
        key: keyForTrigger,
        children: [
          for (int i = 0; i < positions.length; i++)
            Positioned(
              left: positions[i].dx,
              top: positions[i].dy,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i.isEven
                      ? AppColors.gradientStart
                      : AppColors.gradientEnd,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (i.isEven
                              ? AppColors.gradientStart
                              : AppColors.gradientEnd)
                          .withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.6, 1.6),
                    duration: 700.ms,
                    curve: Curves.easeOut,
                    delay: (i * 30).ms,
                  )
                  .fadeOut(duration: 700.ms, delay: (i * 30).ms),
            ),
        ],
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
                              color: selected ? AppColors.surface : AppColors.ink,
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

  // --- bottom bar (floating chevron CTA on Dates / Budget steps) ---
  Widget _bottomBar(BuildContext context, WizardState state) {
    final showButton = state.step == 2 || state.step == 3;
    if (!showButton) return const SizedBox(height: 16);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            opacity: state.canAdvance ? 1 : 0.4,
            child: GestureDetector(
              onTap: state.canAdvance
                  ? () {
                      HapticFeedback.lightImpact();
                      context.read<WizardCubit>().next();
                    }
                  : null,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: state.canAdvance
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  LucideIcons.arrowRight,
                  size: 28,
                  color: AppColors.surface,
                ),
              )
                  .animate(onPlay: state.canAdvance ? (c) => c.repeat(reverse: true) : null)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.06, 1.06),
                    duration: 1400.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pickup dropdown helpers
// ---------------------------------------------------------------------------

class _PickupItem {
  final WizardPickup value;
  final IconData icon;
  final String label;
  const _PickupItem(this.value, this.icon, this.label);
}

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
    return widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: AppTypography.body(size: 14, color: AppColors.ink),
                          decoration: InputDecoration(
                            hintText: 'Rechercher…',
                            hintStyle: AppTypography.body(
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: AppColors.softWarm.withValues(alpha: 0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.accent,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
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
  bool _isStart = true;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = widget.state.startDate ?? today;
    final end = widget.state.endDate ?? start.add(const Duration(days: 1));
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final fmtTime = DateFormat('HH:mm', 'fr_FR');

    final pickerDate = _isStart ? start : end;
    final minDate = _isStart
        ? DateTime(today.year, today.month, today.day)
        : start;
    final maxDate = today.add(const Duration(days: 90));
    final hasBoth = widget.state.startDate != null && widget.state.endDate != null;

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
                selected: _isStart,
                onTap: () => setState(() => _isStart = true),
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
                selected: !_isStart,
                onTap: () => setState(() => _isStart = false),
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
              color: _isStart
                  ? AppColors.accent.withValues(alpha: 0.25)
                  : AppColors.border,
              width: _isStart ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              if (_isStart)
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
                key: ValueKey(_isStart ? 'start' : 'end'),
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: pickerDate,
                minimumDate: minDate,
                maximumDate: maxDate,
                onDateTimeChanged: (date) {
                  if (_isStart) {
                    context.read<WizardCubit>().setStartDate(date);
                  } else {
                    context.read<WizardCubit>().setEndDate(date);
                  }
                },
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
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms),
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
  final VoidCallback onTap;

  const _DatePill({
    required this.label,
    required this.dateText,
    this.timeText = '',
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
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
                : AppColors.border,
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
      ),
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
