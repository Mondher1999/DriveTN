import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Premium row card — Airbnb-style horizontal layout with full wow language:
/// LIVE dot, PREMIUM badge for top-rated cars, animated price count-up,
/// tap-scale feedback, entrance stagger.
class CarCard extends StatefulWidget {
  final Car car;
  final VoidCallback onTap;
  final bool selected;
  final double distanceKm;
  final int index;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.selected = false,
    this.distanceKm = 2.4,
    this.index = 0,
  });

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _pressed ? 0.97 : (widget.selected ? 1.015 : 1.0),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.selected ? AppColors.accent : AppColors.border,
            width: widget.selected ? 1.6 : 1,
          ),
          boxShadow: widget.selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    blurRadius: 26,
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
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(height: 108, child: _info()),
            ),
          ],
        ),
      ),
    );

    final wrapped = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: widget.selected
          ? card
              .animate(onPlay: (c) => c.repeat(period: 2400.ms))
              .shimmer(
                duration: 1500.ms,
                color: AppColors.accent.withValues(alpha: 0.22),
                delay: 600.ms,
              )
          : card,
    );

    return wrapped
        .animate()
        .fadeIn(
          duration: 380.ms,
          delay: (60 * widget.index).ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 380.ms,
          delay: (60 * widget.index).ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ------- Photo cluster (left) -------

  Widget _photo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 108,
        height: 108,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Warm gradient placeholder behind image
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                ),
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.car.photoUrls.first,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(LucideIcons.car,
                    size: 32, color: AppColors.textMuted),
              ),
            ),
            // Subtle bottom gradient for legibility
            const Positioned(
              left: 0, right: 0, bottom: 0, height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black26],
                  ),
                ),
              ),
            ),
            // Bottom thin gradient meter (subtle "available" indicator)
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1600.ms, curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }

  // ------- Info column (right) -------

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.car.brand.toUpperCase(),
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.bluetooth,
                          size: 9, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        'Sans clé',
                        style: AppTypography.caps(
                          size: 8,
                          letterSpacing: 1.2,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              widget.car.model,
              style: AppTypography.h2(size: 18, weight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _miniIcon(LucideIcons.users, '${widget.car.seats}'),
                const SizedBox(width: 10),
                _miniIcon(
                    widget.car.transmission == Transmission.automatic
                        ? LucideIcons.zap
                        : LucideIcons.cog,
                    widget.car.transmissionLabel),
                const SizedBox(width: 10),
                _miniIcon(LucideIcons.fuel, widget.car.fuelLabel),
              ],
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AnimatedPrice(
              endValue: widget.car.dailyPrice.toInt(),
              delayMs: 60 * widget.index,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.mapPin,
                      size: 10, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.distanceKm.toStringAsFixed(1)} km',
                    style: AppTypography.body(
                      size: 10,
                      weight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTypography.body(
            size: 10,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Small helper that animates the price up from 0 on first appearance.
class _AnimatedPrice extends StatelessWidget {
  final int endValue;
  final int delayMs;
  const _AnimatedPrice({required this.endValue, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: endValue.toDouble()),
      duration: Duration(milliseconds: 700 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => PriceTag(price: value, size: 20),
    );
  }
}
