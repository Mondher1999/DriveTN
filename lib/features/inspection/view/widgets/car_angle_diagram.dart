import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';

/// Hybrid guide: real Unsplash car photo + EXPLICIT angle overlay
/// (centered icon + label + arrow) that makes the targeted angle unambiguous
/// regardless of the photo composition.
class CarAngleDiagram extends StatelessWidget {
  final int step;
  const CarAngleDiagram({super.key, required this.step});

  /// Specific Unsplash car photos by angle.
  /// These are well-known IDs; if any fails to load, fallback painter kicks in.
  static const _photoUrls = [
    // FRONT — yellow Mustang front (very recognizable)
    'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=720&h=480&fit=crop&q=75',
    // REAR — back of a parked car
    'https://images.unsplash.com/photo-1601362840469-51e4d8d58785?w=720&h=480&fit=crop&q=75',
    // LEFT side profile — clean side view
    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=720&h=480&fit=crop&q=75',
    // RIGHT side profile
    'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=720&h=480&fit=crop&q=75',
    // INTERIOR — dashboard cockpit
    'https://images.unsplash.com/photo-1503054504624-7c20a87c0ab4?w=720&h=480&fit=crop&q=75',
  ];

  static const _angleLabels = [
    'AVANT',
    'ARRIÈRE',
    'CÔTÉ GAUCHE',
    'CÔTÉ DROIT',
    'INTÉRIEUR',
  ];

  static const _focusAreas = [
    'Phares · grille · plaque',
    'Feux arrière · coffre · plaque',
    'Roues · portes · ligne de toit',
    'Roues · portes · ligne de toit',
    'Volant · tableau de bord · km',
  ];

  static const _icons = [
    LucideIcons.car,            // FRONT
    LucideIcons.car,            // REAR
    LucideIcons.arrowRight,     // LEFT — show "right" arrow (looking at left side)
    LucideIcons.arrowLeft,      // RIGHT — show "left" arrow
    LucideIcons.gauge,          // INTERIOR
  ];

  @override
  Widget build(BuildContext context) {
    final s = step.clamp(0, 4);
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1 — soft gradient background (always visible)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.softWarm,
                    AppColors.softWarm.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            // Layer 2 — real Unsplash photo
            CachedNetworkImage(
              imageUrl: _photoUrls[s],
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 220),
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
              imageBuilder: (_, image) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      AppColors.ink.withValues(alpha: 0.18),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            // Layer 3 — top-to-bottom dark gradient for caption legibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            // Layer 4 — coral corner brackets (camera viewfinder)
            const Positioned.fill(
              child: CustomPaint(painter: _ViewfinderPainter()),
            ),
            // Layer 5 — center "what to film" big icon + label
            Center(
              child: _CenterAngleBadge(
                icon: _icons[s],
                label: _angleLabels[s],
              ),
            ),
            // Layer 6 — top-left step counter badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${s + 1}/5',
                      style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 1.4,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.camera,
                        size: 10, color: AppColors.surface),
                  ],
                ),
              ),
            ),
            // Layer 7 — bottom focus instruction
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.eye,
                      size: 12,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'À CADRER',
                          style: AppTypography.caps(
                            size: 8,
                            letterSpacing: 1.6,
                            color: AppColors.surface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          _focusAreas[s],
                          style: AppTypography.body(
                            size: 11,
                            weight: FontWeight.w800,
                            color: AppColors.surface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

/// Big centered angle badge — gradient circle with icon + label below.
/// This is the UNAMBIGUOUS visual indicator regardless of photo quality.
class _CenterAngleBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CenterAngleBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            shape: BoxShape.circle,
            border:
                Border.all(color: AppColors.surface, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: AppColors.surface),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 2,
              color: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gradientStart
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const m = 6.0;
    const len = 14.0;

    canvas.drawLine(const Offset(m, m), const Offset(m + len, m), paint);
    canvas.drawLine(const Offset(m, m), const Offset(m, m + len), paint);
    canvas.drawLine(
        Offset(size.width - m, m), Offset(size.width - m - len, m), paint);
    canvas.drawLine(
        Offset(size.width - m, m), Offset(size.width - m, m + len), paint);
    canvas.drawLine(Offset(m, size.height - m),
        Offset(m + len, size.height - m), paint);
    canvas.drawLine(Offset(m, size.height - m),
        Offset(m, size.height - m - len), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m),
        Offset(size.width - m - len, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, size.height - m),
        Offset(size.width - m, size.height - m - len), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) => false;
}
