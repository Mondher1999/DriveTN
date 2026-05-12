import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/car.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// WOW card — glassmorphism, cinematic photo, micro-interactions.
/// Premium experience faithful to the Sunset Tunisia palette.
class CarCard extends StatefulWidget {
  final Car car;
  final VoidCallback onTap;
  final bool selected;
  final int index;
  final bool? likedOverride;
  final VoidCallback? onLikeTap;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.selected = false,
    this.index = 0,
    this.likedOverride,
    this.onLikeTap,
  });

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool _pressed = false;
  bool _localLiked = false;

  bool get _isLiked => widget.likedOverride ?? _localLiked;

  @override
  Widget build(BuildContext context) {
    final agency = MockData.agencyById(widget.car.agencyId);
    final isTopPick = widget.car.rating >= 4.8 && widget.car.reviewsCount > 80;

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
        scale: _pressed ? 0.965 : 1.0,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.selected
                  ? AppColors.accent.withValues(alpha: 0.45)
                  : AppColors.border,
              width: widget.selected ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -3,
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: _pressed ? 0.08 : 0.0),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _photo(isTopPick),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
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
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: AppColors.borderStrong,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.car.year}',
                                    style: AppTypography.caps(
                                      size: 9,
                                      letterSpacing: 1.2,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.car.model,
                                style: AppTypography.h1(
                                  size: 18,
                                  weight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Price with count-up
                        _AnimatedPrice(
                          value: widget.car.dailyPrice.toInt(),
                          delayMs: 60 * widget.index,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating + agency
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 3),
                        Text(
                          widget.car.rating.toStringAsFixed(1),
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          ' (${widget.car.reviewsCount})',
                          style: AppTypography.body(
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.borderStrong,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (agency != null)
                          Expanded(
                            child: Text(
                              agency.name,
                              style: AppTypography.body(
                                size: 11,
                                color: AppColors.textSecondary,
                                weight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Feature chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _chip(LucideIcons.users, '${widget.car.seats}p'),
                        _chip(
                          widget.car.transmission == Transmission.automatic
                              ? LucideIcons.zap
                              : LucideIcons.cog,
                          widget.car.transmissionLabel,
                        ),
                        _chip(LucideIcons.fuel, widget.car.fuelLabel),
                        _chip(LucideIcons.car, widget.car.categoryLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * widget.index).ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (50 * widget.index).ms);
  }

  Widget _photo(bool isTopPick) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder gradient
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
                child: Icon(LucideIcons.car, size: 40, color: AppColors.textMuted),
              ),
            ),
            // Cinematic dark gradient top
            Positioned(
              top: 0, left: 0, right: 0, height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            // Cinematic dark gradient bottom
            Positioned(
              bottom: 0, left: 0, right: 0, height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                    ],
                  ),
                ),
              ),
            ),
            // TOP PICK badge (top-left, glassmorphic)
            if (isTopPick)
              Positioned(
                top: 10, left: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: AppColors.surface),
                          const SizedBox(width: 3),
                          Text(
                            'TOP CHOIX',
                            style: AppTypography.caps(
                              size: 8,
                              letterSpacing: 1.2,
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideX(begin: -0.3, end: 0, duration: 500.ms, delay: 200.ms),
            // Rating glassmorphic badge (top-left if no TOP PICK)
            if (!isTopPick)
              Positioned(
                top: 10, left: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            widget.car.rating.toStringAsFixed(1),
                            style: AppTypography.body(size: 12, weight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Heart glassmorphic (top-right)
            Positioned(
              top: 10, right: 10,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onLikeTap != null) {
                    widget.onLikeTap!();
                  } else {
                    setState(() => _localLiked = !_localLiked);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: _isLiked ? 1.2 : 1.0,
                        curve: Curves.easeOutBack,
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: _isLiked ? AppColors.danger : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Photo pagination dots (if multiple photos)
            if (widget.car.photoUrls.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < widget.car.photoUrls.length.clamp(1, 5); i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: i == 0 ? 14 : 6,
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? AppColors.surface
                              : AppColors.surface.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
              ),
            // LIVE dot (bottom-right, only if no pagination)
            if (widget.car.photoUrls.length <= 1)
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1200.ms),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.body(
              size: 10,
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
      builder: (_, v, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
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
          Text(
            '/jour',
            style: AppTypography.body(
              size: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
