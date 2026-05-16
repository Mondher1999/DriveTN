import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class BluetoothLockScreen extends StatefulWidget {
  final String bookingId;
  const BluetoothLockScreen({super.key, required this.bookingId});

  @override
  State<BluetoothLockScreen> createState() =>
      _BluetoothLockScreenState();
}

class _BluetoothLockScreenState extends State<BluetoothLockScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  static const _labels = [
    'Connexion au véhicule',
    'Verrouillage en cours',
    'Verrouillée.',
  ];

  late final AnimationController _arcCtrl;
  late final AnimationController _innerCtrl;

  @override
  void initState() {
    super.initState();
    _arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _innerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false);
    _runSequence();
  }

  @override
  void dispose() {
    _arcCtrl.dispose();
    _innerCtrl.dispose();
    super.dispose();
  }

  Future<void> _runSequence() async {
    for (var i = 1; i < _labels.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _step = i);
      if (i == _labels.length - 1) HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _step == _labels.length - 1;
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom;
    final isCompact = mq.size.height < 820;
    final circleSize = isCompact ? 220.0 : 240.0;
    return Scaffold(
      body: SunsetGradient(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, safeBottom + 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— RESTITUTION',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${_step + 1} / ${_labels.length}',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 2,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: circleSize,
                          height: circleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!isDone) ..._rotatingArcs(),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.surface
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface
                                        .withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  isDone
                                      ? LucideIcons.lock
                                      : LucideIcons.bluetooth,
                                  size: 48,
                                  color: AppColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            _labels[_step],
                            key: ValueKey(_step),
                            style: AppTypography.display(
                              size: 28,
                              weight: FontWeight.w800,
                              color: AppColors.surface,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDone)
                  PrimaryButton(
                    label: 'Voir le récapitulatif',
                    icon: LucideIcons.arrowRight,
                    variant: ButtonVariant.light,
                    onPressed: () => context
                        .go('/return/success/${widget.bookingId}'),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _rotatingArcs() {
    return [
      RotationTransition(
        turns: _arcCtrl,
        child: CustomPaint(
          size: const Size(220, 220),
          painter: _DashedArcPainter(
            color: AppColors.surface.withValues(alpha: 0.55),
            strokeWidth: 1.5,
            dashCount: 24,
            gapRatio: 0.55,
          ),
        ),
      ),
      RotationTransition(
        turns: ReverseAnimation(_innerCtrl),
        child: CustomPaint(
          size: const Size(170, 170),
          painter: _DashedArcPainter(
            color: AppColors.surface.withValues(alpha: 0.32),
            strokeWidth: 1,
            dashCount: 36,
            gapRatio: 0.7,
          ),
        ),
      ),
    ];
  }
}

class _DashedArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;
  final double gapRatio;
  _DashedArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
    required this.gapRatio,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const fullArc = 2 * 3.14159265;
    final dashArc = (fullArc / dashCount) * (1 - gapRatio);
    for (int i = 0; i < dashCount; i++) {
      final start = (fullArc * i) / dashCount;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth),
        start,
        dashArc,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedArcPainter old) =>
      old.color != color ||
      old.dashCount != dashCount ||
      old.gapRatio != gapRatio;
}
