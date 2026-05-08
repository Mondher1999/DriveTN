import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Premium DriveTN map pin (Getaround-inspired).
///
/// - Default pill: gradient sunset (corail→ambre) with white stroke,
///   car icon + WiFi antenna on top + price, plus LIVE dot and optional
///   PREMIUM star badge.
/// - Selected: expands to a tilted mini-card with photo, name, rating chip,
///   specs line, big price, chevron arrow, and a continuous shimmer.
/// - Entrance: staggered fadeIn + scale.
class CarMapMarker extends StatelessWidget {
  final int dailyPrice;
  final bool selected;
  final bool bluetooth;
  final String? photoUrl;
  final String? carName;
  final double rating;
  final String metaText; // e.g. "5 places · Auto · Essence"
  final int index;

  bool get isPremium => rating >= 4.8;

  const CarMapMarker({
    super.key,
    required this.dailyPrice,
    this.selected = false,
    this.bluetooth = false,
    this.photoUrl,
    this.carName,
    this.rating = 4.5,
    this.metaText = '',
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isCard = selected && photoUrl != null && carName != null;
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (selected) ..._haloRings(),
              _pillOrCard(),
            ],
          ),
          // Drop tail (only for the pill, not the mini-card).
          if (!isCard)
            CustomPaint(
              size: const Size(14, 8),
              painter: _PinTailPainter(),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            duration: 400.ms, delay: (40 * index).ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: (40 * index).ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _pillOrCard() {
    if (selected && photoUrl != null && carName != null) {
      return Transform.rotate(
        angle: -0.025, // ~ -1.4° tilt for personality
        child: _miniCard(),
      );
    }
    return _pill();
  }

  // ------------------- Default pill -------------------

  Widget _pill() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.surface, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.28),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
              isPremium ? 22 : 7, 4, 11, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Car + WiFi indicator stack.
              SizedBox(
                width: 16,
                height: 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      bottom: 0,
                      child: Icon(
                        LucideIcons.car,
                        size: 14,
                        color: AppColors.surface,
                      ),
                    ),
                    Positioned(
                      top: -1,
                      child: Icon(
                        LucideIcons.wifi,
                        size: 7,
                        color: AppColors.surface.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$dailyPrice DT',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.surface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        // PREMIUM star badge (left side, overlapping)
        if (isPremium)
          Positioned(
            left: -2,
            top: -2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.gradientStart, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppColors.warning,
                size: 16,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                ),
          ),
        // LIVE availability dot (top-right)
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 1100.ms, curve: Curves.easeInOut),
        ),
      ],
    );
  }

  // ------------------- Selected mini-card -------------------

  Widget _miniCard() {
    return Container(
      width: 220,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.softWarm, Color(0xFFFFF1B8)],
                      ),
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const Icon(
                      LucideIcons.car,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (bluetooth)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.bluetooth,
                          size: 8,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        carName!,
                        style: AppTypography.body(
                          size: 11,
                          weight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 9, color: AppColors.warning),
                          const SizedBox(width: 1),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTypography.body(
                              size: 9,
                              weight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (metaText.isNotEmpty)
                  Text(
                    metaText,
                    style: AppTypography.body(
                      size: 8,
                      color: AppColors.textMuted,
                      weight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$dailyPrice',
                      style: AppTypography.numeric(
                        size: 14,
                        weight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'DT/j',
                      style: AppTypography.caps(
                        size: 7,
                        letterSpacing: 1.2,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.arrowRight,
                        size: 10,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(period: 2400.ms))
        .shimmer(
          duration: 1500.ms,
          color: AppColors.accent.withValues(alpha: 0.3),
          delay: 600.ms,
        );
  }

  // ------------------- Halo pulses -------------------

  List<Widget> _haloRings() {
    return List.generate(2, (i) {
      return IgnorePointer(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.55),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(2.2, 2.2),
              duration: 1900.ms,
              delay: (i * 700).ms,
              curve: Curves.easeOut,
            )
            .fadeOut(
              duration: 1900.ms,
              delay: (i * 700).ms,
              curve: Curves.easeOut,
            ),
      );
    });
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) => false;
}
