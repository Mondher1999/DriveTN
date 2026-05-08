import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Coral Manrope 800 numerals with subtle "DT / jour" tail.
class PriceTag extends StatelessWidget {
  final double price;
  final bool perDay;
  final double size;
  final Color? color;

  const PriceTag({
    super.key,
    required this.price,
    this.perDay = true,
    this.size = 28,
    this.color,
  });

  static String _num(double v) =>
      NumberFormat('#,##0', 'fr_FR').format(v);

  /// "1,200 DT" — kept for backward compat with existing call sites.
  static String format(double v) => '${_num(v)} DT';

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _num(price),
          style: AppTypography.numeric(
            size: size,
            weight: FontWeight.w800,
            color: c,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          perDay ? 'DT / jour' : 'DT',
          style: AppTypography.body(
            size: size * 0.4,
            weight: FontWeight.w600,
            color: c.withValues(alpha: 0.65),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
