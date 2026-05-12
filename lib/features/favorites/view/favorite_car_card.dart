import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/car.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Airbnb-style listing card.
/// - Image is a standalone rounded rectangle (not clipped inside a card).
/// - Clean text below, no visible white card container.
/// - Subtle, spacious, premium feel matching DriveTN palette.
class FavoriteCarCard extends StatefulWidget {
  final Car car;
  final VoidCallback onTap;
  final bool liked;
  final VoidCallback onLikeTap;
  final int index;

  const FavoriteCarCard({
    super.key,
    required this.car,
    required this.onTap,
    required this.liked,
    required this.onLikeTap,
    this.index = 0,
  });

  @override
  State<FavoriteCarCard> createState() => _FavoriteCarCardState();
}

class _FavoriteCarCardState extends State<FavoriteCarCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final agency = MockData.agencyById(widget.car.agencyId);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _pressed ? 0.98 : 1.0,
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Photo block (standalone rounded) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base gradient placeholder
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                          ),
                        ),
                      ),
                      // Photo
                      CachedNetworkImage(
                        imageUrl: widget.car.photoUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox.shrink(),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(LucideIcons.car,
                              size: 40, color: AppColors.textMuted),
                        ),
                      ),
                      // Top-right heart (simple, no glass bubble)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onLikeTap();
                          },
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            scale: widget.liked ? 1.15 : 1.0,
                            curve: Curves.easeOutBack,
                            child: Icon(
                              widget.liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 26,
                              color: widget.liked
                                  ? AppColors.danger
                                  : AppColors.surface,
                            ),
                          ),
                        ),
                      ),
                      // Pagination dots (bottom center)
                      if (widget.car.photoUrls.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0;
                                  i < widget.car.photoUrls.length.clamp(1, 5);
                                  i++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2.5),
                                  width: i == 0 ? 16 : 6,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? AppColors.surface
                                        : AppColors.surface
                                            .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Text content (Airbnb-inspired UX) ──
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Model (hero)  |  Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.car.model,
                              style: AppTypography.h1(
                                size: 22,
                                weight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.car.brand} · ${widget.car.year} · ${widget.car.categoryLabel}',
                              style: AppTypography.body(
                                size: 14,
                                color: AppColors.textSecondary,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _AnimatedPrice(
                        value: widget.car.dailyPrice.toInt(),
                        delayMs: 60 * widget.index,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: Rating + Agency (trust line)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.rating.toStringAsFixed(1),
                        style: AppTypography.body(
                          size: 15,
                          weight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' (${widget.car.reviewsCount} avis)',
                        style: AppTypography.body(
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.borderStrong,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (agency != null)
                        Expanded(
                          child: Text(
                            agency.name,
                            style: AppTypography.body(
                              size: 14,
                              color: AppColors.textSecondary,
                              weight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 3: Feature chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(LucideIcons.users, '${widget.car.seats} places'),
                      _chip(
                        widget.car.transmission == Transmission.automatic
                            ? LucideIcons.zap
                            : LucideIcons.cog,
                        widget.car.transmissionLabel,
                      ),
                      _chip(LucideIcons.fuel, widget.car.fuelLabel),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * widget.index).ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: (50 * widget.index).ms);
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated price counter with DT suffix.
class _AnimatedPrice extends StatelessWidget {
  final int value;
  final int delayMs;
  const _AnimatedPrice({required this.value, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: Duration(milliseconds: 700 + delayMs.clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$v DT',
            style: AppTypography.numeric(
              size: 20,
              weight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '/jour',
            style: AppTypography.body(
              size: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
