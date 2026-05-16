import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class IdentityScanScreen extends StatefulWidget {
  final String carId;
  const IdentityScanScreen({super.key, required this.carId});

  @override
  State<IdentityScanScreen> createState() => _IdentityScanScreenState();
}

class _IdentityScanScreenState extends State<IdentityScanScreen>
    with TickerProviderStateMixin {
  // Phase: 0 = CIN, 1 = passport (both required, sequential)
  int _phase = 0;
  // Sub-step within CIN: 0 = recto, 1 = verso
  int _cinStep = 0;
  bool _isScanning = false;
  bool _capturedRecto = false;
  bool _capturedVerso = false;
  bool _capturedPassport = false;
  bool _capturedPermis = false;

  late final AnimationController _scanLineCtrl;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startScan();
    });
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  bool get _isComplete =>
      _capturedRecto && _capturedVerso && _capturedPassport && _capturedPermis;

  // 0 = CIN recto, 1 = CIN verso, 2 = Passeport, 3 = Permis
  int get _currentStepIndex {
    if (!_capturedRecto) return 0;
    if (!_capturedVerso) return 1;
    if (!_capturedPassport) return 2;
    return 3;
  }

  String get _currentLabel {
    if (_phase == 0) {
      return _cinStep == 0 ? 'CIN — RECTO' : 'CIN — VERSO';
    }
    if (_phase == 1) return 'PASSEPORT';
    return 'PERMIS DE CONDUIRE';
  }

  String get _statusText {
    if (_isComplete) return 'Identité vérifiée — CIN + passeport + permis ✓';
    if (_isScanning) return 'Détection en cours...';
    return 'Cadrez votre document dans le rectangle ci-dessus.';
  }

  void _startScan() {
    if (_isComplete || _isScanning) return;
    setState(() => _isScanning = true);
    _scanLineCtrl.repeat();
    _scanTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _scanLineCtrl.stop();
      setState(() {
        _isScanning = false;
        if (_phase == 0) {
          if (_cinStep == 0) {
            _capturedRecto = true;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              setState(() => _cinStep = 1);
              _startScan();
            });
          } else {
            _capturedVerso = true;
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              setState(() => _phase = 1);
              _startScan();
            });
          }
        } else if (_phase == 1) {
          _capturedPassport = true;
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;
            setState(() => _phase = 2);
            _startScan();
          });
        } else {
          _capturedPermis = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _progress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '— VÉRIFICATION',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Vos',
                          style: AppTypography.display(
                            size: 32,
                            weight: FontWeight.w900,
                            letterSpacing: -1.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'papiers.',
                            style: AppTypography.display(
                              size: 32,
                              weight: FontWeight.w300,
                              italic: true,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "CIN + Passeport + Permis — c'est rapide.",
                      style: AppTypography.body(
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _stepTracker(),
                    const SizedBox(height: 16),
                    _scannerArea(),
                    const SizedBox(height: 16),
                    _statusBanner(),
                    if (_capturedRecto ||
                        _capturedVerso ||
                        _capturedPassport ||
                        _capturedPermis) ...[
                      const SizedBox(height: 16),
                      _capturedThumbnails(),
                    ],
                  ],
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    final mq = MediaQuery.of(context);
    final isCompact = mq.size.height < 820;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, isCompact ? 8 : 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 18,
                color: AppColors.ink,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '— IDENTITÉ',
            style: AppTypography.caps(
              size: 11,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go('/booking/${widget.carId}/agency-validation'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Text(
                'Passer',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    final captured = (_capturedRecto ? 1 : 0) +
        (_capturedVerso ? 1 : 0) +
        (_capturedPassport ? 1 : 0) +
        (_capturedPermis ? 1 : 0);
    double pct = captured / 4.0;
    if (pct == 0 && _isScanning) pct = 0.12;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: AppColors.border),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: pct.clamp(0.0, 1.0),
                heightFactor: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientEnd,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepTracker() {
    final steps = <(String, String, bool, bool)>[
      ('①', 'CIN — Recto', _capturedRecto, _currentStepIndex == 0),
      ('②', 'CIN — Verso', _capturedVerso, _currentStepIndex == 1),
      ('③', 'Passeport', _capturedPassport, _currentStepIndex == 2),
      ('④', 'Permis de conduire', _capturedPermis, _currentStepIndex == 3),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _trackerRow(
              numeral: steps[i].$1,
              label: steps[i].$2,
              done: steps[i].$3,
              active: steps[i].$4 && !steps[i].$3,
            ),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  margin: const EdgeInsets.only(left: 11),
                  width: 2,
                  height: 12,
                  color: AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _trackerRow({
    required String numeral,
    required String label,
    required bool done,
    required bool active,
  }) {
    final Widget dot;
    if (done) {
      dot = Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.check,
          size: 14,
          color: AppColors.surface,
        ),
      );
    } else if (active) {
      dot = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            numeral,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w900,
              color: AppColors.surface,
            ),
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 1100.ms,
            curve: Curves.easeInOut,
          );
    } else {
      dot = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Text(
            numeral,
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        dot,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body(
              size: 13,
              weight: active || done ? FontWeight.w800 : FontWeight.w600,
              color: done
                  ? AppColors.success
                  : (active ? AppColors.ink : AppColors.textMuted),
            ),
          ),
        ),
        if (done)
          Text(
            'OK',
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 1.4,
              color: AppColors.success,
            ),
          )
        else if (active)
          Text(
            'EN COURS',
            style: AppTypography.caps(
              size: 9,
              letterSpacing: 1.4,
              color: AppColors.accent,
            ),
          )
        else
          Text(
            'À VENIR',
            style: AppTypography.caps(
              size: 9,
              letterSpacing: 1.4,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _scannerArea() {
    final bool isCurrentDone;
    if (_phase == 0) {
      isCurrentDone = _cinStep == 0 ? _capturedRecto : _capturedVerso;
    } else if (_phase == 1) {
      isCurrentDone = _capturedPassport;
    } else {
      isCurrentDone = _capturedPermis;
    }

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.ink,
                      AppColors.ink.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isCurrentDone
                        ? AppColors.success.withValues(alpha: 0.18)
                        : AppColors.surface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentDone
                          ? AppColors.success
                          : AppColors.surface.withValues(alpha: 0.18),
                      width: isCurrentDone ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCurrentDone
                              ? LucideIcons.check
                              : (_phase == 2
                                  ? LucideIcons.fileText
                                  : (_phase == 1
                                      ? LucideIcons.bookOpen
                                      : LucideIcons.creditCard)),
                          size: 36,
                          color: isCurrentDone
                              ? AppColors.success
                              : AppColors.surface.withValues(alpha: 0.55),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isCurrentDone ? 'DÉTECTÉ' : _currentLabel,
                          style: AppTypography.caps(
                            size: 11,
                            letterSpacing: 2,
                            color: isCurrentDone
                                ? AppColors.success
                                : AppColors.surface.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanLineCtrl,
                  builder: (_, __) {
                    return Positioned(
                      left: 28,
                      right: 28,
                      top: 28 +
                          (_scanLineCtrl.value *
                                  (MediaQuery.of(context).size.width - 56) *
                                  11 /
                                  16 -
                              56),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x00FF5E3A),
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                              Color(0x00FFB800),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const Positioned.fill(
                child: CustomPaint(painter: _BracketsPainter()),
              ),
              if (_isScanning)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fadeOut(duration: 700.ms),
                        const SizedBox(width: 6),
                        Text(
                          'SCAN',
                          style: AppTypography.caps(
                            size: 9,
                            letterSpacing: 1.6,
                            color: AppColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isCurrentDone)
                ...List.generate(8, (i) {
                  return Positioned(
                    left: 30.0 + (i * 35.0) % 200,
                    top: 30.0 + ((i * 27.0) % 130),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? AppColors.gradientStart
                            : AppColors.gradientEnd,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1.6, 1.6),
                          duration: 700.ms,
                          delay: (i * 50).ms,
                        )
                        .fadeOut(duration: 700.ms, delay: (i * 50).ms),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isScanning
                  ? AppColors.accent.withValues(alpha: 0.14)
                  : (_isComplete
                      ? AppColors.success.withValues(alpha: 0.14)
                      : AppColors.softWarm),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isScanning
                  ? LucideIcons.scan
                  : (_isComplete ? LucideIcons.check : LucideIcons.info),
              size: 14,
              color: _isScanning
                  ? AppColors.accent
                  : (_isComplete ? AppColors.success : AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusText,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _capturedThumbnails() {
    final items = <(String, bool)>[
      ('Recto', _capturedRecto),
      ('Verso', _capturedVerso),
      ('Passeport', _capturedPassport),
      ('Permis', _capturedPermis),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .where((e) => e.$2)
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.check,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.$1,
                    style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 1.2,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 380.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
          )
          .toList(),
    );
  }

  Widget _bottomBar() {
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom;
    final isCompact = mq.size.height < 820;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, safeBottom + (isCompact ? 8 : 16)),
      child: PrimaryButton(
        label: 'Continuer vers paiement',
        icon: LucideIcons.arrowRight,
        variant: ButtonVariant.gradient,
        onPressed: _isComplete
            ? () {
                HapticFeedback.lightImpact();
                context.go('/booking/${widget.carId}/agency-validation');
              }
            : null,
      ),
    );
  }
}

class _BracketsPainter extends CustomPainter {
  const _BracketsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gradientStart
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const m = 16.0;
    const len = 22.0;
    canvas.drawLine(const Offset(m, m), const Offset(m + len, m), paint);
    canvas.drawLine(const Offset(m, m), const Offset(m, m + len), paint);
    canvas.drawLine(
      Offset(size.width - m, m),
      Offset(size.width - m - len, m),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - m, m),
      Offset(size.width - m, m + len),
      paint,
    );
    canvas.drawLine(
      Offset(m, size.height - m),
      Offset(m + len, size.height - m),
      paint,
    );
    canvas.drawLine(
      Offset(m, size.height - m),
      Offset(m, size.height - m - len),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - m, size.height - m),
      Offset(size.width - m - len, size.height - m),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - m, size.height - m),
      Offset(size.width - m, size.height - m - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BracketsPainter old) => false;
}
