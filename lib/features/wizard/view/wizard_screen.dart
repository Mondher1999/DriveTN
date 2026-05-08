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
      (WizardUseCase.city, LucideIcons.building, 'Ville', 'Citadine pratique', null),
      (WizardUseCase.business, LucideIcons.briefcase, 'Business', 'Berline élégante', null),
      (WizardUseCase.weekend, LucideIcons.sun, 'Weekend', "Pour s'évader", 'POPULAIRE'),
      (WizardUseCase.family, LucideIcons.users, 'Famille', 'SUV spacieux', null),
      (WizardUseCase.electric, LucideIcons.zap, 'Électrique', '0 émission', 'ÉCO'),
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
      (WizardCarType.suv, LucideIcons.truck, 'SUV', 'Espace & robustesse', null),
      (WizardCarType.utility, LucideIcons.package, 'Utilitaire', 'Cargo & déménagement', null),
      (WizardCarType.electric, LucideIcons.zap, 'Électrique', '0 émission', 'ÉCO'),
      (WizardCarType.any, LucideIcons.shuffle, 'Peu importe', 'Toutes options', null),
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
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final today = DateTime.now();
    return _stepLayout(
      label: '— ÉTAPE 3 / 8',
      title: 'Quelles',
      titleItalic: 'dates ?',
      subtitle: 'Quand voulez-vous partir ?',
      child: Column(
        children: [
          _dateRow(
            context: context,
            label: 'DÉBUT',
            date: state.startDate,
            formatted: state.startDate != null ? fmt.format(state.startDate!) : 'Choisir',
            isPlaceholder: state.startDate == null,
            icon: LucideIcons.calendar,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.startDate ?? today,
                firstDate: today,
                lastDate: today.add(const Duration(days: 90)),
                locale: const Locale('fr', 'FR'),
                builder: (c, child) => Theme(
                  data: Theme.of(c).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.accent,
                      onPrimary: AppColors.surface,
                      onSurface: AppColors.ink,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null && context.mounted) {
                context.read<WizardCubit>().setStartDate(picked);
              }
            },
          ),
          const SizedBox(height: 12),
          _dateRow(
            context: context,
            label: 'FIN',
            date: state.endDate,
            formatted: state.endDate != null ? fmt.format(state.endDate!) : 'Choisir',
            isPlaceholder: state.endDate == null,
            icon: LucideIcons.calendarDays,
            onTap: () async {
              final base = state.startDate ?? today;
              final picked = await showDatePicker(
                context: context,
                initialDate: state.endDate ?? base.add(const Duration(days: 1)),
                firstDate: base.add(const Duration(days: 1)),
                lastDate: base.add(const Duration(days: 90)),
                locale: const Locale('fr', 'FR'),
                builder: (c, child) => Theme(
                  data: Theme.of(c).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.accent,
                      onPrimary: AppColors.surface,
                      onSurface: AppColors.ink,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null && context.mounted) {
                context.read<WizardCubit>().setEndDate(picked);
              }
            },
          ),
          if (state.startDate != null && state.endDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.softWarm, AppColors.softWarm.withValues(alpha: 0.4)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.clock, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('DURÉE', style: AppTypography.caps(size: 10, letterSpacing: 1.6, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(
                    '${state.durationDays} jour${state.durationDays > 1 ? 's' : ''}',
                    style: AppTypography.numeric(size: 18, weight: FontWeight.w900, color: AppColors.accent, letterSpacing: -0.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateRow({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required String formatted,
    required bool isPlaceholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaceholder ? AppColors.border : AppColors.accent.withValues(alpha: 0.4),
            width: isPlaceholder ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.softWarm,
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
                  Text(label, style: AppTypography.caps(size: 9, letterSpacing: 1.6, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: AppTypography.h2(
                      size: 17,
                      weight: FontWeight.w800,
                      color: isPlaceholder ? AppColors.textMuted : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
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
    final items = <(WizardPickup, IconData, String, String)>[
      (WizardPickup.tunisCentre, LucideIcons.building, 'Tunis Centre', 'Avenue Bourguiba'),
      (WizardPickup.laMarsa, LucideIcons.palmtree, 'La Marsa', 'Front de mer'),
      (WizardPickup.lac1, LucideIcons.briefcase, 'Lac 1', 'Quartier d\'affaires'),
      (WizardPickup.lac2, LucideIcons.building2, 'Lac 2', 'Centre business'),
      (WizardPickup.ariana, LucideIcons.home, 'Ariana', 'Résidentiel nord'),
      (WizardPickup.soukra, LucideIcons.trees, 'Soukra', 'Parcs & verdure'),
      (WizardPickup.carthage, LucideIcons.landmark, 'Carthage', 'Site historique'),
      (WizardPickup.any, LucideIcons.shuffle, 'Peu importe', 'Au choix de l\'agence'),
    ];
    return _stepLayout(
      label: '— ÉTAPE 8 / 8',
      title: 'Lieu de',
      titleItalic: 'prise en charge ?',
      subtitle: 'Le quartier où récupérer (et restituer) la voiture.',
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
              selected: state.pickup == item.$1,
              icon: item.$2,
              title: item.$3,
              caption: item.$4,
              badge: null,
              onTap: () async {
                HapticFeedback.mediumImpact();
                context.read<WizardCubit>().setPickup(item.$1);
                await Future.delayed(const Duration(milliseconds: 420));
                if (context.mounted) {
                  _finish(context, context.read<WizardCubit>().state);
                }
              },
            ),
        ],
      ),
    );
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: AppTypography.display(
                  size: 36,
                  weight: FontWeight.w900,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                titleItalic,
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
