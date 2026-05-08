import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/rental_cubit.dart';
import '../bloc/rental_state.dart';

class ActiveRentalScreen extends StatefulWidget {
  final String bookingId;
  const ActiveRentalScreen({super.key, required this.bookingId});

  @override
  State<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends State<ActiveRentalScreen> {
  RentalCubit? _rentalCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalCubit>().start(widget.bookingId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rentalCubit ??= context.read<RentalCubit>();
  }

  @override
  void dispose() {
    _rentalCubit?.stop();
    super.dispose();
  }

  String _fmtDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final booking = MockData.bookingById(widget.bookingId);
    final deposit = booking?.depositAmount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '— EN COURS',
          style: AppTypography.label(
            size: 11,
            letterSpacing: 2.4,
            color: AppColors.textMuted,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RentalCubit, RentalState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _heroBlock(state),
              const SizedBox(height: 16),
              _statsRow(state, deposit),
              const SizedBox(height: 16),
              _mapBlock(state),
              const SizedBox(height: 24),
              _actionRow(state),
              const SizedBox(height: 24),
              PrimaryButton(
                variant: ButtonVariant.gradient,
                label: 'Terminer la location',
                icon: LucideIcons.arrowRight,
                onPressed: () {
                  context.read<RentalCubit>().stop();
                  context.push('/inspection/return/${widget.bookingId}');
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _heroBlock(RentalState state) {
    // 200km cap for distance arc; fuel 0–100; both visualized as arcs.
    final kmProgress = (state.kilometers / 200).clamp(0.0, 1.0);
    final fuelProgress = (state.fuelPercent / 100).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '— EN COURSE',
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 2.4,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).fadeOut(
                        duration: 1200.ms, curve: Curves.easeInOut),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 1.6,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Distance arc (outer)
                CustomPaint(
                  size: const Size(240, 240),
                  painter: _GaugeArcPainter(
                    progress: kmProgress,
                    strokeWidth: 8,
                    baseColor: AppColors.border,
                    gradientColors: const [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                    startAngle: -3.14159 * 0.75,
                    sweepAngle: 3.14159 * 1.5,
                  ),
                ),
                // Fuel arc (inner)
                CustomPaint(
                  size: const Size(192, 192),
                  painter: _GaugeArcPainter(
                    progress: fuelProgress,
                    strokeWidth: 5,
                    baseColor: AppColors.border,
                    gradientColors: [
                      state.fuelPercent < 30
                          ? AppColors.warning
                          : AppColors.ink,
                      state.fuelPercent < 30
                          ? AppColors.danger
                          : AppColors.ink,
                    ],
                    startAngle: -3.14159 * 0.75,
                    sweepAngle: 3.14159 * 1.5,
                  ),
                ),
                // Center timer
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TEMPS',
                      style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 2.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fmtDuration(state.elapsed),
                      style: AppTypography.numeric(
                        size: 38,
                        weight: FontWeight.w800,
                        color: AppColors.ink,
                        italic: false,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(width: 28, height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    Text(
                      'Profitez du voyage —',
                      style: AppTypography.body(
                        size: 11,
                        italic: true,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _gaugeLegend(
                gradient: true,
                label: 'KM',
                value: '${state.kilometers}',
                cap: '/ 200',
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              _gaugeLegend(
                gradient: false,
                color: state.fuelPercent < 30
                    ? AppColors.warning
                    : AppColors.ink,
                label: 'FUEL',
                value: '${state.fuelPercent}',
                cap: '%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gaugeLegend({
    bool gradient = false,
    Color? color,
    required String label,
    required String value,
    required String cap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 4,
          decoration: BoxDecoration(
            color: gradient ? null : color,
            gradient: gradient
                ? const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  )
                : null,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caps(
            size: 9,
            letterSpacing: 1.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.numeric(
                size: 22,
                weight: FontWeight.w800,
                color: AppColors.ink,
                italic: false,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              cap,
              style: AppTypography.body(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsRow(RentalState state, double deposit) {
    final fuelColor =
        state.fuelPercent < 30 ? AppColors.warning : AppColors.ink;
    return Row(
      children: [
        Expanded(
          child: _statTile(
            label: 'KM PARCOURUS',
            value: '${state.kilometers}',
            valueColor: AppColors.ink,
            caption: 'Distance',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            label: 'CARBURANT',
            value: '${state.fuelPercent}%',
            valueColor: fuelColor,
            caption: 'Réservoir',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            label: 'CAUTION',
            value: PriceTag.format(deposit),
            valueColor: AppColors.accent,
            caption: 'Bloquée',
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color valueColor,
    required String caption,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 1.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.numeric(
                size: 24,
                italic: true,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: AppTypography.body(
              size: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBlock(RentalState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: state.currentPosition,
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.drivetn.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: state.currentPosition,
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.surface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.accent.withValues(alpha: 0.5),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.car,
                          size: 12,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(RentalState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleAction(
          icon: state.isLocked ? LucideIcons.lock : LucideIcons.unlock,
          label: state.isLocked ? 'VERROUILLÉ' : 'OUVERT',
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<RentalCubit>().toggleLock();
          },
        ),
        _circleAction(
          icon: LucideIcons.lifeBuoy,
          label: 'SOS',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('SOS', style: AppTypography.serif(size: 18)),
                content: Text(
                  'Mode démo · appel fictif',
                  style: AppTypography.body(size: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
        _circleAction(
          icon: LucideIcons.messageCircle,
          label: 'MESSAGES',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title:
                    Text('Messages', style: AppTypography.serif(size: 18)),
                content: Text(
                  'Mode démo',
                  style: AppTypography.body(size: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.ink, size: 22),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 1.8,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _GaugeArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color baseColor;
  final List<Color> gradientColors;
  final double startAngle;
  final double sweepAngle;

  _GaugeArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.baseColor,
    required this.gradientColors,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, base);

    if (progress > 0) {
      final fg = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: gradientColors,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle * progress, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.gradientColors != gradientColors;
}
