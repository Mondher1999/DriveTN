import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;
  final int? reviewsCount;
  final ValueChanged<int>? onRate;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = false,
    this.reviewsCount,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onRate == null ? null : () => onRate!(i),
            child: Icon(
              i <= rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: AppColors.warning,
            ),
          ),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (reviewsCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewsCount)',
              style: TextStyle(
                fontSize: size * 0.85,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
