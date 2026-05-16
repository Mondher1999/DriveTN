import 'dart:async';
import 'dart:math' show Random, pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/game_cubit.dart';
import '../bloc/game_state.dart';

/// 🏎️ Endless Drive Tunisia — Infinite racing mini-game
/// Play while waiting for agency validation. Keeps playing even after
/// 5 minutes if no response. When agency confirms, popup appears.
class EndlessDriveGame extends StatefulWidget {
  final String carId;
  const EndlessDriveGame({super.key, required this.carId});

  @override
  State<EndlessDriveGame> createState() => _EndlessDriveGameState();
}

class _EndlessDriveGameState extends State<EndlessDriveGame>
    with TickerProviderStateMixin {
  static const int _totalWaitSeconds = 300; // 5 minutes
  int _elapsedSeconds = 0;
  bool _agencyNotified = false;
  Timer? _waitTimer;
  Timer? _agencyConfirmTimer;

  late final AnimationController _roadScrollCtrl;
  late final AnimationController _carBounceCtrl;
  late final AnimationController _coinRotateCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _laneSlideCtrl;
  late final AnimationController _roadLinesCtrl;

  final List<double> _laneX = [0.25, 0.5, 0.75];
  late final GameCubit _gameCubit;

  // Visual effects state
  final List<_Particle> _particles = [];
  int _comboCount = 0;
  final Random _rand = Random();

  // Previous state tracking for effect triggers
  int _lastCoins = 0;
  double _lastSpeed = 8.0;
  int _lastLane = 1;
  int _lastLevel = 1;
  bool _showLevelUp = false;

  @override
  void initState() {
    super.initState();
    _gameCubit = context.read<GameCubit>();

    // If returning after quitting a previous game, reset so start screen shows
    if (_gameCubit.state.gameOver) {
      _gameCubit.prepareNewGame();
    }

    _roadScrollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _carBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _coinRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _laneSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _roadLinesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _startWaitTimer();
    _simulateAgencyResponse();
  }

  void _startWaitTimer() {
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });

      // After 5 minutes, show "we'll notify you" popup
      if (_elapsedSeconds >= _totalWaitSeconds && !_agencyNotified) {
        _agencyNotified = true;
        _showWaitPopup();
      }
    });
  }

  void _simulateAgencyResponse() {
    // Agency responds randomly between 30s and 4 minutes
    final delay = 30 + Random().nextInt(210);
    _agencyConfirmTimer = Timer(Duration(seconds: delay), () {
      if (mounted) {
        _gameCubit.agencyConfirm();
        _showConfirmationPopup();
      }
    });
  }

  void _startGame() {
    _gameCubit.startGame();
  }

  void _moveLane(int direction) {
    _gameCubit.moveLane(direction);
  }

  void _quitGame() {
    final state = _gameCubit.state;
    if (state.gameStarted && !state.gameOver) {
      _gameCubit.endGame();
    }
    if (mounted) {
      context.pop();
    }
  }

  void _showWaitPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bell, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Validation en cours',
              style: AppTypography.h1(size: 20, weight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "L'agence n'a pas encore répondu. On vous notifiera le plus tôt possible !",
              style: AppTypography.body(size: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Continuer à jouer',
                  style: AppTypography.body(
                    size: 15,
                    weight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationPopup() {
    final coins = _gameCubit.state.coins;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check, color: Colors.white, size: 32),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              "L'agence a accepté !",
              style: AppTypography.h1(size: 22, weight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre réservation est confirmée. Passez au paiement !',
              style: AppTypography.body(size: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.coins, size: 16, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    '$coins DT de bonus !',
                    style: AppTypography.body(
                        size: 14, weight: FontWeight.w700, color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _goToPayment();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Payer maintenant',
                  style: AppTypography.body(
                    size: 15,
                    weight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.push('/game-leaderboard');
                Navigator.of(context).pop();
              },
              child: Text(
                'Voir les scores',
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPayment() {
    if (mounted) {
      final coins = _gameCubit.state.coins;
      context.read<BookingCubit>().applyGameBonus(coins);
      context.go('/booking/${widget.carId}/payment');
    }
  }

  @override
  void dispose() {
    final state = _gameCubit.state;
    if (state.gameStarted && !state.gameOver) {
      _gameCubit.endGame();
    }
    _waitTimer?.cancel();
    _agencyConfirmTimer?.cancel();
    _roadScrollCtrl.dispose();
    _carBounceCtrl.dispose();
    _coinRotateCtrl.dispose();
    _shakeCtrl.dispose();
    _glowCtrl.dispose();
    _laneSlideCtrl.dispose();
    _roadLinesCtrl.dispose();
    super.dispose();
  }

  void _spawnParticles(double x, double y) {
    final colors = [
      AppColors.gradientStart,
      AppColors.gradientEnd,
      AppColors.accent,
      Colors.amber,
      Colors.orange,
      Colors.white,
    ];
    for (int i = 0; i < 8; i++) {
      final angle = _rand.nextDouble() * 2 * pi;
      final velocity = 20 + _rand.nextDouble() * 40;
      _particles.add(_Particle(
        x: x,
        y: y,
        color: colors[_rand.nextInt(colors.length)],
        dx: cos(angle) * velocity,
        dy: sin(angle) * velocity,
        createdAt: DateTime.now(),
      ));
    }
  }

  void _clearOldParticles() {
    final now = DateTime.now();
    _particles.removeWhere((p) => now.difference(p.createdAt).inMilliseconds > 500);
  }

  Widget _buildParticle(_Particle p) {
    final age = DateTime.now().difference(p.createdAt).inMilliseconds;
    const lifetime = 500;
    final progress = (age / lifetime).clamp(0.0, 1.0);
    return Positioned(
      left: p.x + p.dx * progress,
      top: p.y + p.dy * progress,
      child: Opacity(
        opacity: (1.0 - progress).clamp(0.0, 1.0),
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: p.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (previous, current) {
        return previous.coins != current.coins ||
            previous.speed != current.speed ||
            previous.lane != current.lane ||
            previous.level != current.level ||
            previous.boostTimeLeft != current.boostTimeLeft ||
            previous.hasShield != current.hasShield ||
            previous.hasMagnet != current.hasMagnet ||
            previous.multiplierTimeLeft != current.multiplierTimeLeft;
      },
      listener: (context, state) {
        // Detect coin collection
        if (state.coins > _lastCoins) {
          final laneX = _laneX[state.lane] * MediaQuery.of(context).size.width;
          _spawnParticles(laneX, 650);
          _comboCount++;
        }
        // Detect obstacle hit (speed dropped significantly)
        if (state.speed < _lastSpeed * 0.85 && state.speed < 8.0) {
          _shakeCtrl.forward(from: 0);
          _comboCount = 0;
        }
        // Detect lane change for slide animation
        if (state.lane != _lastLane) {
          _laneSlideCtrl.forward(from: 0);
        }
        // Detect level up
        if (state.level > _lastLevel) {
          _showLevelUp = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) setState(() => _showLevelUp = false);
          });
        }
        _lastCoins = state.coins;
        _lastSpeed = state.speed;
        _lastLane = state.lane;
        _lastLevel = state.level;
        _clearOldParticles();
      },
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          _clearOldParticles();
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: SafeArea(
              child: GestureDetector(
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < width * 0.4) {
                    _moveLane(-1); // Left tap
                  } else if (details.globalPosition.dx > width * 0.6) {
                    _moveLane(1); // Right tap
                  }
                },
                child: AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (_, child) {
                    double dx = 0;
                    if (_shakeCtrl.isAnimating) {
                      dx = sin(_shakeCtrl.value * pi * 6) * 8;
                    }
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: Stack(
                    children: [
                      // 🌅 Background sky with desert
                      _buildSky(),

                      // 🏜️ Parallax desert layers
                      _buildParallaxLayers(),

                      // 🛣️ Road
                      _buildRoad(),

                      // ⚡ Speed lines
                      if (state.speed > 12) _buildSpeedLines(),

                      // 🌴 Side scenery
                      _buildScenery(state),

                      if (state.gameStarted && !state.gameOver) ...[
                        // 🎯 Game objects (coins & obstacles)
                        ...state.objects.map((obj) => _buildObject(obj)),

                        // ✨ Particles
                        ..._particles.map((p) => _buildParticle(p)),

                        // 🏎️ Player car
                        _buildPlayerCar(state),

                        // 🔥 Combo multiplier
                        if (_comboCount >= 3) _buildComboText(),

                        // 🆙 Level up message
                        if (_showLevelUp) _buildLevelUpText(state),

                        // 📊 HUD
                        _buildHUD(state),
                      ],

                      if (state.gameOver) _buildGameOverScreen(state),

                      if (!state.gameStarted && !state.gameOver) _buildStartScreen(),

                      // ⏱️ Top timer bar
                      _buildTimerBar(),

                      // ❌ Close / back to waiting screen
                      Positioned(
                        top: 12,
                        right: 16,
                        child: GestureDetector(
                          onTap: _quitGame,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.x,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSky() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF9A76), // Sunset orange
                Color(0xFFFF6B6B), // Coral
                Color(0xFF4A1C40), // Deep purple
                Color(0xFF1A1A2E), // Dark blue
              ],
            ),
          ),
        ),
        // Stars
        CustomPaint(
          size: Size.infinite,
          painter: _StarsPainter(),
        ),
        // Sun
        Positioned(
          top: 80,
          right: 40,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFFFE4B5),
                  Color(0xFFFF9A76),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF9A76).withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoad() {
    return Center(
      child: SizedBox(
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Road surface ──
            Container(
              width: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A3A4E),
                    Color(0xFF2A2A3E),
                    Color(0xFF1A1A2E),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Lane dividers (faint vertical lines)
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Container(
                          width: 2,
                          color: Colors.white.withValues(alpha: 0.06)),
                      Expanded(child: Container()),
                      Container(
                          width: 2,
                          color: Colors.white.withValues(alpha: 0.06)),
                      Expanded(child: Container()),
                    ],
                  ),
                  // Animated dashed center lines
                  AnimatedBuilder(
                    animation: _roadLinesCtrl,
                    builder: (_, __) {
                      return CustomPaint(
                        size: Size(280, MediaQuery.of(context).size.height),
                        painter: _RoadLinesPainter(
                          progress: _roadLinesCtrl.value,
                          speed: _gameCubit.state.speed,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // ── Left shoulder (red/white) ──
            Positioned(
              left: 0,
              child: _buildShoulderStripes(isLeft: true),
            ),
            // ── Right shoulder (red/white) ──
            Positioned(
              right: 0,
              child: _buildShoulderStripes(isLeft: false),
            ),
            // ── White solid edge lines ──
            Positioned(
              left: 19,
              child: Container(
                width: 2,
                height: MediaQuery.of(context).size.height,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              right: 19,
              child: Container(
                width: 2,
                height: MediaQuery.of(context).size.height,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoulderStripes({required bool isLeft}) {
    return AnimatedBuilder(
      animation: _roadLinesCtrl,
      builder: (_, __) {
        final shift = (_roadLinesCtrl.value * 120) % 60;
        return SizedBox(
          width: 18,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Dark shoulder base
              Container(
                width: 18,
                height: double.infinity,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
              ),
              // Red/white diagonal stripes
              for (int i = -1; i < 30; i++)
                Positioned(
                  top: (i * 60.0) + shift - 60,
                  left: isLeft ? 0 : null,
                  right: isLeft ? null : 0,
                  child: Transform.rotate(
                    angle: isLeft ? -0.35 : 0.35,
                    child: Container(
                      width: 24,
                      height: 30,
                      color: i.isEven
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScenery(GameState state) {
    // Use distance (always increasing) so objects scroll continuously
    // without snapping back. Each item has its own spacing and speed factor.
    final d = state.distance;

    // Helper that computes a continuous Y from distance
    double scrollY(double spacing, double speedFactor) {
      final raw = d * speedFactor;
      return -(raw % spacing);
    }

    return Stack(
      children: [
        // ── LEFT side ──
        Positioned(
          left: 18,
          bottom: scrollY(350, 0.55) + 100,
          child: _buildPalmTree(),
        ),
        Positioned(
          left: 36,
          bottom: scrollY(420, 0.60) + 280,
          child: _buildCactus(),
        ),
        Positioned(
          left: 14,
          bottom: scrollY(380, 0.50) + 480,
          child: _buildRock(),
        ),
        Positioned(
          left: 42,
          bottom: scrollY(460, 0.58) + 180,
          child: _buildBush(),
        ),
        Positioned(
          left: 22,
          bottom: scrollY(520, 0.62) + 360,
          child: _buildElectricPole(),
        ),
        Positioned(
          left: 30,
          bottom: scrollY(400, 0.52) + 560,
          child: _buildDune(),
        ),

        // ── RIGHT side ──
        Positioned(
          right: 18,
          bottom: scrollY(370, 0.56) + 140,
          child: _buildPalmTree(),
        ),
        Positioned(
          right: 32,
          bottom: scrollY(440, 0.61) + 320,
          child: _buildStreetLamp(),
        ),
        Positioned(
          right: 16,
          bottom: scrollY(390, 0.53) + 520,
          child: _buildCactus(),
        ),
        Positioned(
          right: 38,
          bottom: scrollY(480, 0.59) + 220,
          child: _buildRock(),
        ),
        Positioned(
          right: 24,
          bottom: scrollY(500, 0.64) + 400,
          child: _buildSign(),
        ),
        Positioned(
          right: 30,
          bottom: scrollY(410, 0.54) + 600,
          child: _buildBush(),
        ),
      ],
    );
  }

  // ── Individual scenery builders ──

  Widget _buildPalmTree() {
    return SizedBox(
      width: 34,
      height: 70,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Trunk
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B6914).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Leaves
          Positioned(
            top: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.9),
                    const Color(0xFF2E7D32).withValues(alpha: 0.4),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.treePine, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCactus() {
    return Container(
      width: 24,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(LucideIcons.sprout, color: Colors.white70, size: 18),
      ),
    );
  }

  Widget _buildStreetLamp() {
    return SizedBox(
      width: 18,
      height: 80,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pole
          Positioned(
            top: 24,
            child: Container(
              width: 3,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[600]!.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Light
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFE082).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Lamp arm
          Positioned(
            top: 20,
            child: Container(
              width: 14,
              height: 2,
              color: Colors.grey[600]!.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRock() {
    return Container(
      width: 28,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF795548).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }

  Widget _buildBush() {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF66BB6A).withValues(alpha: 0.6),
            const Color(0xFF388E3C).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(LucideIcons.clover, color: Colors.white54, size: 16),
    );
  }

  Widget _buildDune() {
    return Container(
      width: 50,
      height: 18,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD7CCC8).withValues(alpha: 0.4),
            const Color(0xFF8D6E63).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }

  Widget _buildSign() {
    return SizedBox(
      width: 20,
      height: 50,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pole
          Positioned(
            top: 16,
            child: Container(
              width: 3,
              height: 34,
              color: Colors.grey[500]!.withValues(alpha: 0.7),
            ),
          ),
          // Board
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.arrowUp, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricPole() {
    return SizedBox(
      width: 22,
      height: 72,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Pole
          Positioned(
            top: 8,
            child: Container(
              width: 4,
              height: 64,
              color: const Color(0xFF6D4C41).withValues(alpha: 0.8),
            ),
          ),
          // Crossbar
          Container(
            width: 22,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF6D4C41).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Wires (tiny dots)
          Positioned(
            top: 4,
            left: 2,
            child: Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
          ),
          Positioned(
            top: 4,
            right: 2,
            child: Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCar(GameState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([_carBounceCtrl, _glowCtrl, _laneSlideCtrl]),
      builder: (_, __) {
        final width = MediaQuery.of(context).size.width;
        final targetLaneX = _laneX[state.lane] * width;
        final laneX = targetLaneX;

        // Speed factor for glow intensity
        final speedFactor = (state.speed / 20).clamp(0.0, 1.0);
        final pulse = _glowCtrl.value;
        final glowOpacity = 0.3 + pulse * 0.3 + speedFactor * 0.4;
        final glowRadius = 25 + pulse * 20 + speedFactor * 30;
        final isNitro = state.boostTimeLeft > 0;

        return Positioned(
          bottom: 110 + (_carBounceCtrl.value * 4),
          left: laneX - 35,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 🔥 Nitro flames behind car
              if (isNitro)
                Positioned(
                  top: 75,
                  left: 5,
                  child: AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) {
                      final flameHeight = 40 + _glowCtrl.value * 30;
                      return Container(
                        width: 60,
                        height: flameHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF00D2FF).withValues(alpha: 0.8),
                              const Color(0xFF3A7BD5).withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),

              // Trail glow behind car
              if (speedFactor > 0.3)
                Positioned(
                  top: 70,
                  left: 10,
                  child: Container(
                    width: 50,
                    height: 60 + speedFactor * 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.gradientStart.withValues(alpha: 0.5 + speedFactor * 0.3),
                          AppColors.gradientEnd.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

              // 🛡️ Shield bubble
              if (state.hasShield)
                Positioned(
                  top: -10,
                  left: -15,
                  child: Container(
                    width: 100,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4776E6).withValues(alpha: 0.6 + pulse * 0.3),
                        width: 2,
                      ),
                      color: const Color(0xFF4776E6).withValues(alpha: 0.08 + pulse * 0.08),
                    ),
                  ),
                ),

              // Main car body
              Container(
                width: 70,
                height: 90,
                child: CustomPaint(
                  size: const Size(70, 90),
                  painter: _SportsCarPainter(
                    speedFactor: speedFactor,
                    pulse: pulse,
                  ),
                ),
              ),

              // Outer glow
              Positioned(
                top: -5,
                left: -5,
                right: -5,
                bottom: -5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isNitro
                            ? const Color(0xFF00D2FF).withValues(alpha: glowOpacity)
                            : AppColors.gradientStart.withValues(alpha: glowOpacity),
                        blurRadius: glowRadius,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: glowOpacity * 0.3),
                        blurRadius: glowRadius * 0.5,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParallaxLayers() {
    return Stack(
      children: [
        _buildParallaxLayer(speed: 0.2, color: const Color(0xFF2A1A3E), height: 120, offset: 0),
        _buildParallaxLayer(speed: 0.5, color: const Color(0xFF4A1C3C), height: 100, offset: 40),
        _buildParallaxLayer(speed: 0.9, color: const Color(0xFF6B2E2E), height: 80, offset: 80),
      ],
    );
  }

  Widget _buildParallaxLayer({
    required double speed,
    required Color color,
    required double height,
    required double offset,
  }) {
    return AnimatedBuilder(
      animation: _roadScrollCtrl,
      builder: (_, __) {
        final shift = (_roadScrollCtrl.value * 200 * speed) % 200;
        return Positioned(
          bottom: offset + 100,
          left: -shift,
          right: -200 + shift,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width + 200, height),
            painter: _HillPainter(color: color),
          ),
        );
      },
    );
  }

  Widget _buildSpeedLines() {
    return AnimatedBuilder(
      animation: _roadScrollCtrl,
      builder: (_, __) {
        final shift = (_roadScrollCtrl.value * 200) % 100;
        return Stack(
          children: [
            for (int i = 0; i < 4; i++)
              Positioned(
                top: (i * 150).toDouble() + shift * 2 - 100,
                left: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            for (int i = 0; i < 4; i++)
              Positioned(
                top: (i * 150 + 75).toDouble() + shift * 2 - 100,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildComboText() {
    final multiplier = (_comboCount ~/ 3);
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'x$multiplier COMBO !',
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        )
            .animate(key: ValueKey<int>(_comboCount))
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0, end: -30, duration: 700.ms, curve: Curves.easeOutQuad)
            .fadeOut(delay: 500.ms, duration: 200.ms),
      ),
    );
  }

  Widget _buildObject(GameObject obj) {
    final laneX = _laneX[obj.lane] * MediaQuery.of(context).size.width;

    switch (obj.type) {
      case ObjectType.coin:
        return AnimatedBuilder(
          animation: _coinRotateCtrl,
          builder: (_, __) {
            return Positioned(
              top: obj.y,
              left: laneX - 15,
              child: Transform.rotate(
                angle: _coinRotateCtrl.value * 2 * pi,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.circleDollarSign,
                      color: Colors.white, size: 16),
                ),
              ),
            );
          },
        );
      case ObjectType.obstacle:
        return Positioned(
          top: obj.y,
          left: laneX - 25,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[700]!.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.alertOctagon,
                color: Colors.white, size: 24),
          ),
        );
      case ObjectType.speedBoost:
        return Positioned(
          top: obj.y,
          left: laneX - 18,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(LucideIcons.zap, color: Colors.white, size: 18),
          ),
        );
      case ObjectType.shield:
        return Positioned(
          top: obj.y,
          left: laneX - 18,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4776E6).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(LucideIcons.shield, color: Colors.white, size: 18),
          ),
        );
      case ObjectType.magnet:
        return Positioned(
          top: obj.y,
          left: laneX - 18,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFAA00FF), Color(0xFFFF00AA)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFAA00FF).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(LucideIcons.magnet, color: Colors.white, size: 18),
          ),
        );
      case ObjectType.coinMultiplier:
        return Positioned(
          top: obj.y,
          left: laneX - 18,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B09B).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
          ),
        );
    }
  }

  Widget _buildHUD(GameState state) {
    final speedKmh = (state.speed * 3.6).toStringAsFixed(0);
    final powerUps = <Widget>[];

    if (state.boostTimeLeft > 0) {
      powerUps.add(_buildPowerUpBadge(
        icon: LucideIcons.zap,
        color: const Color(0xFF00D2FF),
        time: state.boostTimeLeft,
      ));
    }
    if (state.hasShield) {
      powerUps.add(_buildPowerUpBadge(
        icon: LucideIcons.shield,
        color: const Color(0xFF4776E6),
      ));
    }
    if (state.hasMagnet && state.magnetTimeLeft > 0) {
      powerUps.add(_buildPowerUpBadge(
        icon: LucideIcons.magnet,
        color: const Color(0xFFAA00FF),
        time: state.magnetTimeLeft,
      ));
    }
    if (state.coinMultiplier > 1 && state.multiplierTimeLeft > 0) {
      powerUps.add(_buildPowerUpBadge(
        icon: LucideIcons.sparkles,
        color: const Color(0xFF00B09B),
        time: state.multiplierTimeLeft,
      ));
    }

    // Level progress (0.0 - 1.0)
    final levelProgress = (state.distance % 2000) / 2000;

    return Stack(
      children: [
        // ── TOP BAR ──
        Positioned(
          top: 52,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left group: Distance + Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin, size: 13, color: AppColors.gradientStart),
                          const SizedBox(width: 5),
                          Text(
                            '${state.distance.toStringAsFixed(0)} m',
                            style: AppTypography.body(
                                size: 13, weight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NIVEAU ${state.level}',
                        style: AppTypography.body(
                            size: 10, weight: FontWeight.w900, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              // Center: Speedometer compact
              Expanded(
                child: _buildSpeedBadge(state, speedKmh),
              ),
              // Right group: Coins
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.coins, size: 16, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            '${state.coins}',
                            style: AppTypography.body(
                                size: 16, weight: FontWeight.w900, color: Colors.amber),
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

        // ── LEVEL PROGRESS BAR (below top bar) ──
        Positioned(
          top: 110,
          left: 60,
          right: 60,
          child: Column(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: levelProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${(levelProgress * 100).toStringAsFixed(0)}%',
                style: AppTypography.body(size: 9, color: Colors.white54),
              ),
            ],
          ),
        ),

        // ── BOTTOM: Power-ups only ──
        if (powerUps.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: powerUps,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpeedBadge(GameState state, String speedKmh) {
    final isNitro = state.boostTimeLeft > 0;
    final speedFactor = (state.speed / 35).clamp(0.0, 1.0);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isNitro
                ? const Color(0xFF00D2FF).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isNitro
                  ? const Color(0xFF00D2FF).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.gauge,
                size: 14,
                color: isNitro ? const Color(0xFF00D2FF) : const Color(0xFF00D2FF),
              ),
              const SizedBox(width: 5),
              Text(
                speedKmh,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isNitro ? const Color(0xFF00D2FF) : Colors.white,
                  height: 1,
                ),
              ),
              Text(
                ' km/h',
                style: AppTypography.body(size: 10, color: Colors.white54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Mini speed arc
        SizedBox(
          width: 50,
          height: 8,
          child: CustomPaint(
            painter: _MiniSpeedArcPainter(
              progress: speedFactor,
              color: isNitro ? const Color(0xFF00D2FF) : AppColors.gradientStart,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerUpBadge({
    required IconData icon,
    required Color color,
    double? time,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          if (time != null) ...[
            const SizedBox(width: 3),
            Text(
              time.toStringAsFixed(1),
              style: AppTypography.body(size: 10, weight: FontWeight.w800, color: color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelUpText(GameState state) {
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientStart.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Text(
            'Niveau ${state.level} !',
            style: AppTypography.body(
              size: 18,
              weight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        )
            .animate(key: ValueKey<int>(state.level))
            .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack)
            .fadeIn(duration: 200.ms)
            .then(delay: 800.ms)
            .fadeOut(duration: 300.ms),
      ),
    );
  }

  Widget _buildGameOverScreen(GameState state) {
    final speedKmh = (state.bestSpeed * 3.6).toStringAsFixed(0);
    final isNewRecord = state.distance.toInt() > state.bestDistance;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientStart.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(LucideIcons.flag, color: Colors.white, size: 28),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack),
            const SizedBox(height: 14),
            Text(
              'Course terminée !',
              style: AppTypography.h1(size: 20, weight: FontWeight.w900, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (isNewRecord) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.trophy, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Nouveau record !',
                      style: AppTypography.body(size: 11, weight: FontWeight.w800, color: Colors.amber),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
            const SizedBox(height: 20),
            // Stats grid (2x2)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(icon: LucideIcons.mapPin, label: 'Distance', value: '${state.distance.toStringAsFixed(0)} m', color: Colors.white),
                _buildStatCard(icon: LucideIcons.gauge, label: 'Vitesse max', value: '$speedKmh km/h', color: const Color(0xFF00D2FF)),
                _buildStatCard(icon: LucideIcons.coins, label: 'Bonus', value: '${state.coins} DT', color: Colors.amber),
                _buildStatCard(icon: LucideIcons.trophy, label: 'Record', value: '${state.bestDistance} m', color: AppColors.gradientStart),
              ],
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => _gameCubit.prepareNewGame(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Rejouer',
                    style: AppTypography.body(
                        size: 17, weight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.push('/game-leaderboard'),
              child: Text(
                'Tableau des scores',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.body(size: 10, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.body(size: 14, weight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo with strong visual hierarchy
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.gamepad2, color: Colors.white, size: 38),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack)
                  .then()
                  .shake(duration: 400.ms, hz: 3),
              const SizedBox(height: 22),
              // Title
              Text(
                'Endless Drive Tunisia',
                style: AppTypography.h1(
                    size: 24, weight: FontWeight.w900, color: Colors.white),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                'Conduis le plus loin possible !\nGagne des bonus pour ta location.',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: Colors.white60),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms),
              const SizedBox(height: 28),
              // Power-up legend grid (aligned, grouped by proximity)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Power-ups',
                      style: AppTypography.body(size: 11, weight: FontWeight.w800, color: Colors.white54),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPowerUpLegend(LucideIcons.zap, 'Nitro', const Color(0xFF00D2FF)),
                        _buildPowerUpLegend(LucideIcons.shield, 'Bouclier', const Color(0xFF4776E6)),
                        _buildPowerUpLegend(LucideIcons.magnet, 'Aimant', const Color(0xFFAA00FF)),
                        _buildPowerUpLegend(LucideIcons.sparkles, 'x2', const Color(0xFF00B09B)),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 20),
              // Best score badge
              if (_gameCubit.state.bestDistance > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.trophy, size: 13, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Record : ${_gameCubit.state.bestDistance} m',
                        style: AppTypography.body(size: 12, weight: FontWeight.w700, color: Colors.amber.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 24),
              // Main CTA button (large, centered, high contrast)
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Démarrer la course',
                      style: AppTypography.body(
                          size: 17, weight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.2, end: 0, delay: 700.ms),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/game-leaderboard'),
                child: Text(
                  'Tableau des scores',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white60,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 900.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpLegend(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Icon(icon, size: 14, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.body(size: 10, weight: FontWeight.w700, color: color.withValues(alpha: 0.85)),
        ),
      ],
    );
  }

  Widget _buildTimerBar() {
    final progress = _elapsedSeconds / _totalWaitSeconds;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        color: Colors.black.withValues(alpha: 0.3),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Particle model
// ─────────────────────────────────────────────
class _Particle {
  final double x;
  final double y;
  final Color color;
  final double dx;
  final double dy;
  final DateTime createdAt;

  _Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.dx,
    required this.dy,
    required this.createdAt,
  });
}

// ─────────────────────────────────────────────
// Desert hill painter for parallax
// ─────────────────────────────────────────────
class _HillPainter extends CustomPainter {
  final Color color;

  _HillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.5 +
          sin(x / size.width * 4 * pi) * size.height * 0.4 +
          sin(x / size.width * 2 * pi + 1) * size.height * 0.2;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Stars painter for sky
// ─────────────────────────────────────────────
class _StarsPainter extends CustomPainter {
  static final List<Offset> _stars = List.generate(
    60,
    (_) => Offset(
      Random().nextDouble() * 400,
      Random().nextDouble() * 300,
    ),
  );
  static final List<double> _sizes = List.generate(60, (_) => 0.5 + Random().nextDouble() * 1.5);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _stars.length; i++) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 + (i % 3) * 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(_stars[i], _sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Road dashed lines painter
// ─────────────────────────────────────────────
class _RoadLinesPainter extends CustomPainter {
  final double progress;
  final double speed;

  _RoadLinesPainter({required this.progress, required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final dashHeight = 40.0;
    final gapHeight = 50.0 - (speed * 1.5).clamp(0.0, 30.0);
    final total = dashHeight + gapHeight;
    final offset = progress * total;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25 + (speed / 40).clamp(0.0, 0.3))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Left lane divider
    for (double y = -total + offset; y < size.height; y += total) {
      canvas.drawLine(
        Offset(size.width * 0.33, y),
        Offset(size.width * 0.33, (y + dashHeight).clamp(y, size.height)),
        paint,
      );
    }

    // Right lane divider
    for (double y = -total + offset; y < size.height; y += total) {
      canvas.drawLine(
        Offset(size.width * 0.66, y),
        Offset(size.width * 0.66, (y + dashHeight).clamp(y, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoadLinesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.speed != speed;
  }
}

// ─────────────────────────────────────────────
// Sports car painter
// ─────────────────────────────────────────────
class _SportsCarPainter extends CustomPainter {
  final double speedFactor;
  final double pulse;

  _SportsCarPainter({required this.speedFactor, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Lower body (main floor) ──
    final lowerBodyPath = Path()
      ..moveTo(w * 0.48, h * 0.35)
      ..lineTo(w * 0.88, h * 0.38)
      ..lineTo(w * 0.94, h * 0.52)
      ..lineTo(w * 0.92, h * 0.72)
      ..lineTo(w * 0.84, h * 0.82)
      ..lineTo(w * 0.72, h * 0.88)
      ..lineTo(w * 0.28, h * 0.88)
      ..lineTo(w * 0.16, h * 0.82)
      ..lineTo(w * 0.08, h * 0.72)
      ..lineTo(w * 0.06, h * 0.52)
      ..lineTo(w * 0.12, h * 0.38)
      ..close();

    final lowerBodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gradientEnd,
          AppColors.gradientStart.withValues(alpha: 0.95),
          AppColors.gradientEnd.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(lowerBodyPath, lowerBodyPaint);

    // ── Upper body (cabin + hood) ──
    final upperBodyPath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.78, h * 0.22)
      ..lineTo(w * 0.88, h * 0.38)
      ..lineTo(w * 0.48, h * 0.35)
      ..lineTo(w * 0.12, h * 0.38)
      ..lineTo(w * 0.22, h * 0.22)
      ..close();

    final upperBodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gradientStart,
          AppColors.gradientStart.withValues(alpha: 0.85),
          AppColors.gradientEnd.withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(upperBodyPath, upperBodyPaint);

    // ── Outline ──
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawPath(upperBodyPath, outlinePaint);
    canvas.drawPath(lowerBodyPath, outlinePaint);

    // ── Windshield ──
    final windshieldPath = Path()
      ..moveTo(w * 0.35, h * 0.20)
      ..lineTo(w * 0.65, h * 0.20)
      ..lineTo(w * 0.75, h * 0.35)
      ..lineTo(w * 0.25, h * 0.35)
      ..close();

    final windshieldPaint = Paint()
      ..color = const Color(0xFF111122).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(windshieldPath, windshieldPaint);

    // Windshield reflection line
    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.38, h * 0.24),
      Offset(w * 0.58, h * 0.24),
      reflectionPaint,
    );

    // ── Side air intakes ──
    final intakePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Left intake
    final leftIntake = Path()
      ..moveTo(w * 0.10, h * 0.50)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.16, h * 0.62)
      ..lineTo(w * 0.08, h * 0.58)
      ..close();
    canvas.drawPath(leftIntake, intakePaint);

    // Right intake
    final rightIntake = Path()
      ..moveTo(w * 0.90, h * 0.50)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.84, h * 0.62)
      ..lineTo(w * 0.92, h * 0.58)
      ..close();
    canvas.drawPath(rightIntake, intakePaint);

    // ── Aggressive LED headlights ──
    final headlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 + pulse * 0.05)
      ..style = PaintingStyle.fill;

    // Left headlight (slanted L-shape)
    final leftLight = Path()
      ..moveTo(w * 0.10, h * 0.42)
      ..lineTo(w * 0.28, h * 0.40)
      ..lineTo(w * 0.26, h * 0.46)
      ..lineTo(w * 0.12, h * 0.48)
      ..close();
    canvas.drawPath(leftLight, headlightPaint);

    // Right headlight
    final rightLight = Path()
      ..moveTo(w * 0.90, h * 0.42)
      ..lineTo(w * 0.72, h * 0.40)
      ..lineTo(w * 0.74, h * 0.46)
      ..lineTo(w * 0.88, h * 0.48)
      ..close();
    canvas.drawPath(rightLight, headlightPaint);

    // Headlight glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFE4B5).withValues(alpha: 0.25 + pulse * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(w * 0.18, h * 0.44), 10, glowPaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.44), 10, glowPaint);

    // ── Taillights (rear) ──
    final taillightPaint = Paint()
      ..color = Colors.red[400]!.withValues(alpha: 0.85 + pulse * 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.78, w * 0.20, h * 0.035),
        const Radius.circular(3),
      ),
      taillightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.68, h * 0.78, w * 0.20, h * 0.035),
        const Radius.circular(3),
      ),
      taillightPaint,
    );

    // Taillight glow
    final tailGlow = Paint()
      ..color = Colors.red.withValues(alpha: 0.2 + pulse * 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w * 0.22, h * 0.80), 8, tailGlow);
    canvas.drawCircle(Offset(w * 0.78, h * 0.80), 8, tailGlow);

    // ── Big rear spoiler (wing) ──
    final spoilerPaint = Paint()
      ..color = AppColors.gradientEnd.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // Wing posts
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.82, w * 0.04, h * 0.08), spoilerPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.74, h * 0.82, w * 0.04, h * 0.08), spoilerPaint);

    // Wing blade
    final wingPath = Path()
      ..moveTo(w * 0.08, h * 0.88)
      ..lineTo(w * 0.05, h * 0.95)
      ..lineTo(w * 0.95, h * 0.95)
      ..lineTo(w * 0.92, h * 0.88)
      ..close();
    canvas.drawPath(wingPath, spoilerPaint);

    // ── Side mirrors (aerodynamic) ──
    final mirrorPaint = Paint()
      ..color = AppColors.gradientEnd.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.32, w * 0.07, h * 0.05),
        const Radius.circular(3),
      ),
      mirrorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.91, h * 0.32, w * 0.07, h * 0.05),
        const Radius.circular(3),
      ),
      mirrorPaint,
    );

    // ── Wheels (larger, sportier) ──
    final wheelPaint = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;

    final rimInnerPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    // Left wheel
    canvas.drawCircle(Offset(w * 0.22, h * 0.82), w * 0.11, wheelPaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.82), w * 0.07, rimPaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.82), w * 0.035, rimInnerPaint);

    // Right wheel
    canvas.drawCircle(Offset(w * 0.78, h * 0.82), w * 0.11, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.82), w * 0.07, rimPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.82), w * 0.035, rimInnerPaint);

    // ── Racing stripes on hood ──
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.48, h * 0.08),
      Offset(w * 0.46, h * 0.32),
      stripePaint,
    );
    canvas.drawLine(
      Offset(w * 0.52, h * 0.08),
      Offset(w * 0.54, h * 0.32),
      stripePaint,
    );

    // ── Rear diffuser ──
    final diffuserPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.88, w * 0.30, h * 0.04), diffuserPaint);
  }

  @override
  bool shouldRepaint(covariant _SportsCarPainter oldDelegate) {
    return oldDelegate.speedFactor != speedFactor || oldDelegate.pulse != pulse;
  }
}

// ─────────────────────────────────────────────
// Speedometer arc painter
// ─────────────────────────────────────────────
class _MiniSpeedArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniSpeedArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height * 1.5;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Active arc
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSpeedArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
