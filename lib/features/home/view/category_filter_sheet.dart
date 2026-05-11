import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/cars_cubit.dart';

/// Bottom sheet dédié au filtre "Type de véhicule".
/// Grille de chips avec icône + label. Style épuré DriveTN.
class CategoryFilterSheet extends StatefulWidget {
  const CategoryFilterSheet({super.key});

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late Set<CarCategory> _selected;

  static const List<_CategoryItem> _items = [
    _CategoryItem(CarCategory.utility, 'Utilitaire', LucideIcons.truck),
    _CategoryItem(CarCategory.city, 'Citadine', LucideIcons.car),
    _CategoryItem(CarCategory.sedan, 'Berline', LucideIcons.car),
    _CategoryItem(CarCategory.family, 'Familiale', LucideIcons.car),
    _CategoryItem(CarCategory.minibus, 'Minibus', LucideIcons.car),
    _CategoryItem(CarCategory.fourByFour, '4x4', LucideIcons.car),
    _CategoryItem(CarCategory.convertible, 'Cabriolet', LucideIcons.car),
    _CategoryItem(CarCategory.coupe, 'Coupé', LucideIcons.car),
    _CategoryItem(CarCategory.collection, 'Collection', LucideIcons.car),
    _CategoryItem(CarCategory.camperVan, 'Van aménagé', LucideIcons.truck),
    _CategoryItem(CarCategory.suv, 'SUV', LucideIcons.car),
    _CategoryItem(CarCategory.electric, 'Électrique', LucideIcons.zap),
  ];

  @override
  void initState() {
    super.initState();
    _selected = {...context.read<CarsCubit>().state.selectedCategories};
  }

  void _haptic() => HapticFeedback.selectionClick();

  void _toggle(CarCategory cat) {
    _haptic();
    setState(() {
      if (_selected.contains(cat)) {
        _selected.remove(cat);
      } else {
        _selected.add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
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
            // Poignée
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Type de véhicule',
                style: AppTypography.h2(size: 18, weight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 24),
            // Grille
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final item in _items)
                      _CategoryChip(
                        label: item.label,
                        icon: item.icon,
                        selected: _selected.contains(item.category),
                        onTap: () => _toggle(item.category),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Barre d'action
            Container(
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
                      onPressed: () => setState(() => _selected.clear()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Appliquer',
                      variant: ButtonVariant.gradient,
                      onPressed: () {
                        context.read<CarsCubit>().applyFilters(
                              categories: _selected,
                            );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final CarCategory category;
  final String label;
  final IconData icon;
  const _CategoryItem(this.category, this.label, this.icon);
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: selected ? AppColors.softWarm : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.borderStrong,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: selected ? AppColors.accent : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
