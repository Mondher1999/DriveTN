import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/cars_cubit.dart';

/// Sunset Tunisia "Plus de filtres" sheet — light theme reinterpretation
/// of the Getaround filter mockup. Mixes existing CarsCubit dimensions
/// (categories/transmissions/fuels/price) with new visual-only dimensions
/// (min places, recent toggle, equipments, brands).
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // ---- Wired to CarsCubit ----
  late RangeValues _priceRange;
  late Set<Transmission> _transmissions; // single-radio in this UI
  late Set<FuelType> _fuels;
  late Set<CarCategory> _categories; // kept so reset is consistent

  // ---- Local-only (visual demo) ----
  int _minSeats = 2;
  bool _recentOnly = false;
  final Set<String> _equipments = {};
  final Set<String> _brands = {};

  // Single-select transmission radio.
  // null = "Tous", otherwise one of Transmission.values.
  Transmission? _transmissionRadio;

  static const _equipmentOptions = <String>[
    'Siège bébé',
    'GPS',
    'Climatisation',
    'Porte-vélos',
    'Coffre de toit',
    'Caméra recul',
    'Bluetooth',
  ];

  static const _brandOptions = <String>[
    'Renault',
    'Peugeot',
    'Mercedes-Benz',
    'Audi',
    'Hyundai',
    'Volkswagen',
    'Toyota',
    'Fiat',
    'Citroën',
    'Skoda',
    'Kia',
    'Suzuki',
    'Dacia',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<CarsCubit>().state;
    // Clamp price range to the slider bounds to avoid assertion errors.
    final start = state.priceRange.start.clamp(0.0, 1000.0);
    final end = state.priceRange.end.clamp(start, 1000.0);
    _priceRange = RangeValues(start, end);
    _categories = {...state.selectedCategories};
    _transmissions = {...state.selectedTransmissions};
    _fuels = {...state.selectedFuels};
    _transmissionRadio =
        _transmissions.length == 1 ? _transmissions.first : null;
  }

  // ---------------- Helpers ----------------

  String _categoryLabel(CarCategory c) {
    switch (c) {
      case CarCategory.city:
        return 'Citadine';
      case CarCategory.sedan:
        return 'Berline';
      case CarCategory.suv:
        return 'SUV';
      case CarCategory.utility:
        return 'Utilitaire';
      case CarCategory.electric:
        return 'Électrique';
      case CarCategory.family:
        return 'Familiale';
      case CarCategory.minibus:
        return 'Minibus';
      case CarCategory.fourByFour:
        return '4x4';
      case CarCategory.convertible:
        return 'Cabriolet';
      case CarCategory.coupe:
        return 'Coupé';
      case CarCategory.collection:
        return 'Collection';
      case CarCategory.camperVan:
        return 'Van aménagé';
    }
  }

  String _fuelLabel(FuelType f) {
    switch (f) {
      case FuelType.gasoline:
        return 'Essence';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.hybrid:
        return 'Hybride';
      case FuelType.electric:
        return 'Électrique';
    }
  }

  void _haptic() => HapticFeedback.selectionClick();

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sections = <Widget>[
      _placesSection(),
      _divider(),
      _categorySection(),
      _divider(),
      _priceSection(),
      _divider(),
      _recentToggleSection(),
      _divider(),
      _equipmentsSection(),
      _divider(),
      _transmissionSection(),
      _divider(),
      _engineSection(),
      _divider(),
      _brandSection(),
      const SizedBox(height: 8),
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            _header(),
            Container(height: 1, color: AppColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < sections.length; i++)
                      sections[i].animate().fadeIn(
                            delay: Duration(milliseconds: 60 * i),
                            duration: const Duration(milliseconds: 280),
                          ).slideY(
                            begin: 0.05,
                            end: 0,
                            delay: Duration(milliseconds: 60 * i),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          ),
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          _OutlinePill(
            label: 'Fermer',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                'Plus de filtres',
                style: AppTypography.h2(size: 17, weight: FontWeight.w800),
              ),
            ),
          ),
          // Spacer to balance the close pill on the left.
          const SizedBox(width: 84),
        ],
      ),
    );
  }

  // ---------------- Sections ----------------

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label,
          style: AppTypography.h2(size: 17, weight: FontWeight.w800),
        ),
      );

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 24),
        color: AppColors.border,
      );

  Widget _placesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Nombre de places'),
        Row(
          children: [
            Expanded(
              child: Text(
                'Nombre de places min.',
                style: AppTypography.body(size: 14, weight: FontWeight.w500),
              ),
            ),
            Text(
              '$_minSeats',
              style: AppTypography.body(
                size: 16,
                weight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 12),
            _CounterPill(
              onMinus: _minSeats > 2
                  ? () {
                      _haptic();
                      setState(() => _minSeats--);
                    }
                  : null,
              onPlus: _minSeats < 9
                  ? () {
                      _haptic();
                      setState(() => _minSeats++);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Type de véhicule'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in CarCategory.values)
              _SelectableChip(
                label: _categoryLabel(c),
                selected: _categories.contains(c),
                onTap: () {
                  _haptic();
                  setState(() {
                    if (_categories.contains(c)) {
                      _categories.remove(c);
                    } else {
                      _categories.add(c);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _priceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Prix par jour'),
        Row(
          children: [
            Text(
              '${_priceRange.start.toInt()} DT',
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            Text(
              '${_priceRange.end.toInt()} DT',
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 100,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.border,
          labels: RangeLabels(
            '${_priceRange.start.toInt()} DT',
            '${_priceRange.end.toInt()} DT',
          ),
          onChanged: (values) {
            setState(() => _priceRange = values);
          },
        ),
      ],
    );
  }

  Widget _recentToggleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Voitures récentes uniquement'),
        Row(
          children: [
            Expanded(
              child: Text(
                'Moins de 5 ans',
                style: AppTypography.body(size: 14, weight: FontWeight.w500),
              ),
            ),
            Switch.adaptive(
              value: _recentOnly,
              activeThumbColor: AppColors.accent,
              onChanged: (v) {
                _haptic();
                setState(() => _recentOnly = v);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _equipmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Équipements'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in _equipmentOptions)
              _SelectableChip(
                label: e,
                selected: _equipments.contains(e),
                onTap: () {
                  _haptic();
                  setState(() {
                    if (_equipments.contains(e)) {
                      _equipments.remove(e);
                    } else {
                      _equipments.add(e);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _transmissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Boîte de vitesse'),
        _RadioRow(
          label: 'Tous',
          selected: _transmissionRadio == null,
          onTap: () {
            _haptic();
            setState(() {
              _transmissionRadio = null;
              _transmissions.clear();
            });
          },
        ),
        const SizedBox(height: 8),
        _RadioRow(
          label: 'Manuelle',
          selected: _transmissionRadio == Transmission.manual,
          onTap: () {
            _haptic();
            setState(() {
              _transmissionRadio = Transmission.manual;
              _transmissions
                ..clear()
                ..add(Transmission.manual);
            });
          },
        ),
        const SizedBox(height: 8),
        _RadioRow(
          label: 'Automatique',
          selected: _transmissionRadio == Transmission.automatic,
          onTap: () {
            _haptic();
            setState(() {
              _transmissionRadio = Transmission.automatic;
              _transmissions
                ..clear()
                ..add(Transmission.automatic);
            });
          },
        ),
      ],
    );
  }

  Widget _engineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Moteur'),
        // Order: Électrique, Hybride, Essence, Diesel
        for (final f in const [
          FuelType.electric,
          FuelType.hybrid,
          FuelType.gasoline,
          FuelType.diesel,
        ])
          _CheckboxRow(
            label: _fuelLabel(f),
            selected: _fuels.contains(f),
            onTap: () {
              _haptic();
              setState(() {
                if (_fuels.contains(f)) {
                  _fuels.remove(f);
                } else {
                  _fuels.add(f);
                }
              });
            },
          ),
      ],
    );
  }

  Widget _brandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Marque'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in _brandOptions)
              _SelectableChip(
                label: b,
                selected: _brands.contains(b),
                onTap: () {
                  _haptic();
                  setState(() {
                    if (_brands.contains(b)) {
                      _brands.remove(b);
                    } else {
                      _brands.add(b);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  // ---------------- Bottom bar ----------------

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Réinitialiser',
              variant: ButtonVariant.light,
              onPressed: () {
                context.read<CarsCubit>().resetFilters();
                setState(() {
                  final s = context.read<CarsCubit>().state;
                  _priceRange = s.priceRange;
                  _categories = {...s.selectedCategories};
                  _transmissions = {...s.selectedTransmissions};
                  _fuels = {...s.selectedFuels};
                  _transmissionRadio = null;
                  _minSeats = 2;
                  _recentOnly = false;
                  _equipments.clear();
                  _brands.clear();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: 'Appliquer',
              variant: ButtonVariant.gradient,
              onPressed: () {
                context.read<CarsCubit>().applyFilters(
                      priceRange: _priceRange,
                      categories: _categories,
                      transmissions: _transmissions,
                      fuels: _fuels,
                    );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Sub-widgets
// =====================================================================

class _OutlinePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppColors.borderStrong, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  const _CounterPill({this.onMinus, this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderStrong, width: 1),
      ),
      child: Row(
        children: [
          _CounterButton(
            icon: '−',
            enabled: onMinus != null,
            onTap: onMinus,
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.border,
          ),
          _CounterButton(
            icon: '+',
            enabled: onPlus != null,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final String icon;
  final bool enabled;
  final VoidCallback? onTap;
  const _CounterButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 40,
        child: Center(
          child: Text(
            icon,
            style: AppTypography.body(
              size: 18,
              weight: FontWeight.w800,
              color: enabled ? AppColors.ink : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.softWarm : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body(
            size: 13,
            weight: FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      )
                    : null,
                color: selected ? null : AppColors.surface,
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.surface,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CheckboxRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.surface,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
