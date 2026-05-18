import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Full-screen map simulation showing the route from the user to their rental car.
///
/// Uses flutter_map with CartoDB Voyager tiles, a coral pulsing dot for the
/// user, a sunset gradient pin for the car, and a gradient polyline between them.
class SimulationMapScreen extends StatelessWidget {
  final String carId;

  const SimulationMapScreen({super.key, required this.carId});

  // Aéroport Tunis Carthage
  static const _airportLocation = LatLng(36.8510, 10.2272);
  // Voiture à côté (Les Berges du Lac, ~1,5 km)
  static const _carLocation = LatLng(36.8480, 10.2400);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final arrival = now.add(const Duration(minutes: 5));
    final arrivalTime =
        '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full-screen map with fade-in entrance.
          Positioned.fill(
            child: _MapLayer(
              carLocation: _carLocation,
              userLocation: _airportLocation,
            ).animate().fadeIn(duration: 700.ms, curve: Curves.easeOut),
          ),

          // Minimal top bar.
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const _BackButton(),
                const Spacer(),
                Text(
                  'Votre trajet',
                  style: AppTypography.h1(size: 18, color: AppColors.ink),
                ),
                const Spacer(),
                _QuitButton(),
              ],
            ),
          ),

          // Bottom floating card slides up.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCard(
              arrivalTime: arrivalTime,
              onArrived: () => context.go('/inspection/pickup/demo-booking'),
            ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                  delay: 350.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map layer
// ---------------------------------------------------------------------------

class _MapLayer extends StatelessWidget {
  final LatLng carLocation;
  final LatLng userLocation;

  const _MapLayer({required this.carLocation, required this.userLocation});

  List<LatLng> _buildRoutePoints() {
    // Trajet courbé réaliste : Aéroport Tunis Carthage → Les Berges du Lac
    return [
      userLocation,                              // Départ : Aéroport
      const LatLng(36.8505, 10.2285),        // Waypoint 1
      const LatLng(36.8500, 10.2300),        // Waypoint 2
      const LatLng(36.8493, 10.2325),        // Waypoint 3
      const LatLng(36.8487, 10.2350),        // Waypoint 4
      const LatLng(36.8483, 10.2375),        // Waypoint 5
      carLocation,                              // Arrivée : Voiture
    ];
  }

  List<Polyline> _buildPolylines() {
    const segmentsPerLeg = 16;
    final routePoints = _buildRoutePoints();
    final polylines = <Polyline>[];

    // 1. Drop shadow
    for (int leg = 0; leg < routePoints.length - 1; leg++) {
      final start = routePoints[leg];
      final end = routePoints[leg + 1];
      for (int i = 0; i < segmentsPerLeg; i++) {
        final t1 = i / segmentsPerLeg;
        final t2 = (i + 1) / segmentsPerLeg;
        final p1 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t1,
          start.longitude + (end.longitude - start.longitude) * t1,
        );
        final p2 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t2,
          start.longitude + (end.longitude - start.longitude) * t2,
        );
        polylines.add(
          Polyline(
            points: [p1, p2],
            color: AppColors.ink.withValues(alpha: 0.15),
            strokeWidth: 14,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
      }
    }

    // 2. White outline
    for (int leg = 0; leg < routePoints.length - 1; leg++) {
      final start = routePoints[leg];
      final end = routePoints[leg + 1];
      for (int i = 0; i < segmentsPerLeg; i++) {
        final t1 = i / segmentsPerLeg;
        final t2 = (i + 1) / segmentsPerLeg;
        final p1 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t1,
          start.longitude + (end.longitude - start.longitude) * t1,
        );
        final p2 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t2,
          start.longitude + (end.longitude - start.longitude) * t2,
        );
        polylines.add(
          Polyline(
            points: [p1, p2],
            color: AppColors.surface,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
      }
    }

    // 3. Gradient core
    int totalSegments = (routePoints.length - 1) * segmentsPerLeg;
    int currentSegment = 0;
    for (int leg = 0; leg < routePoints.length - 1; leg++) {
      final start = routePoints[leg];
      final end = routePoints[leg + 1];
      for (int i = 0; i < segmentsPerLeg; i++) {
        final t1 = i / segmentsPerLeg;
        final t2 = (i + 1) / segmentsPerLeg;
        final p1 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t1,
          start.longitude + (end.longitude - start.longitude) * t1,
        );
        final p2 = LatLng(
          start.latitude + (end.latitude - start.latitude) * t2,
          start.longitude + (end.longitude - start.longitude) * t2,
        );

        final globalT = currentSegment / totalSegments;
        final color = Color.lerp(
          AppColors.gradientStart,
          AppColors.gradientEnd,
          globalT,
        )!;

        polylines.add(
          Polyline(
            points: [p1, p2],
            color: color,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        );
        currentSegment++;
      }
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (userLocation.latitude + carLocation.latitude) / 2,
      (userLocation.longitude + carLocation.longitude) / 2,
    );

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.6,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.drivetn.app',
        ),
        PolylineLayer(polylines: _buildPolylines()),
        // Halo around the car destination
        CircleLayer(
          circles: [
            CircleMarker(
              point: carLocation,
              radius: 28,
              color: AppColors.accent.withValues(alpha: 0.15),
              borderColor: AppColors.accent.withValues(alpha: 0.3),
              borderStrokeWidth: 1,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: userLocation,
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const _PulsingDot(),
            ),
            Marker(
              point: carLocation,
              width: 56,
              height: 68,
              alignment: Alignment.bottomCenter,
              child: const _CarPin(),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Back button
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          size: 20,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _QuitButton extends StatelessWidget {
  const _QuitButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/rentals'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Quitter',
          style: AppTypography.caps(
            size: 10,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing user dot
// ---------------------------------------------------------------------------

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(2.2, 2.2),
              duration: 1200.ms,
              curve: Curves.easeInOut,
            )
            .fadeOut(duration: 1200.ms, curve: Curves.easeInOut),
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.surface, width: 2.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent,
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Car pin (sunset gradient)
// ---------------------------------------------------------------------------

class _CarPin extends StatelessWidget {
  const _CarPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: -2,
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.car,
            size: 20,
            color: AppColors.surface,
          ),
        ),
        CustomPaint(
          size: const Size(14, 8),
          painter: _PinTailPainter(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pin tail painter
// ---------------------------------------------------------------------------

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

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Bottom floating card
// ---------------------------------------------------------------------------

class _BottomCard extends StatelessWidget {
  final String arrivalTime;
  final VoidCallback onArrived;

  const _BottomCard({required this.arrivalTime, required this.onArrived});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5 min',
              style: AppTypography.numeric(size: 40, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              'Aéroport Tunis Carthage → Votre voiture · Arrivée prévue $arrivalTime',
              style: AppTypography.body(
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onArrived,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "J'y suis",
                  style: AppTypography.body(
                    size: 16,
                    weight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Approchez-vous de la voiture pour déverrouiller',
                style: AppTypography.body(
                  size: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
