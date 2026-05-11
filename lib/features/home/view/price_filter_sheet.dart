import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/cars_cubit.dart';

/// Bottom sheet dédié au filtre de prix — style inspiré du screenshot
/// mais repensé avec la palette Sunset Tunisia (DriveTN).
class PriceFilterSheet extends StatefulWidget {
  const PriceFilterSheet({super.key});

  @override
  State<PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<PriceFilterSheet> {
  late RangeValues _range;

  static const double _min = 50;
  static const double _max = 2000;

  @override
  void initState() {
    super.initState();
    final current = context.read<CarsCubit>().state.priceRange;
    _range = RangeValues(
      current.start.clamp(_min, _max),
      current.end.clamp(_min, _max),
    );
  }

  void _haptic() => HapticFeedback.selectionClick();

  String get _label {
    if (_range.start == _min && _range.end == _max) return 'Tous les prix';
    return '${_range.start.toInt()} DT – ${_range.end.toInt()} DT';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.36,
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
                'Prix total',
                style: AppTypography.h2(size: 18, weight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 28),
            // Contenu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: Theme.of(context).sliderTheme.copyWith(
                          activeTrackColor: AppColors.accent,
                          inactiveTrackColor: AppColors.border,
                          rangeThumbShape: const _PriceThumbShape(),
                          overlayShape: SliderComponentShape.noOverlay,
                          trackHeight: 3,
                          showValueIndicator: ShowValueIndicator.never,
                        ),
                    child: RangeSlider(
                      values: _range,
                      min: _min,
                      max: _max,
                      divisions: 39,
                      onChanged: (v) {
                        _haptic();
                        setState(() => _range = v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
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
                      onPressed: () {
                        setState(() => _range = const RangeValues(_min, _max));
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
                              priceRange: _range,
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

/// Thumb personnalisé pour le RangeSlider : disque blanc avec bordure subtile
/// et ombre portée douce — fidèle au rendu premium du screenshot.
class _PriceThumbShape extends RangeSliderThumbShape {
  const _PriceThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final canvas = context.canvas;

    // Ombre portée
    final shadowPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(0, 2), 11, shadowPaint);

    // Disque blanc
    final fillPaint = Paint()..color = AppColors.surface;
    canvas.drawCircle(center, 11, fillPaint);

    // Bordure fine
    final strokePaint = Paint()
      ..color = AppColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 11, strokePaint);
  }
}
