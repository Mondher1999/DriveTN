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
            previous.lane != current.lane;
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
        _lastCoins = state.coins;
        _lastSpeed = state.speed;
        _lastLane = state.lane;
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
                      _buildScenery(),

                      if (state.gameStarted && !state.gameOver) ...[
                        // 🎯 Game objects (coins & obstacles)
                        ...state.objects.map((obj) => _buildObject(obj)),

                        // ✨ Particles
                        ..._particles.map((p) => _buildParticle(p)),

                        // 🏎️ Player car
                        _buildPlayerCar(state),

                        // 🔥 Combo multiplier
                        if (_comboCount >= 3) _buildComboText(),

                        // 📊 HUD
                        _buildHUD(state),
                      ],

                      if (!state.gameStarted) _buildStartScreen(),

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
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A3A4E),
              Color(0xFF2A2A3E),
              Color(0xFF1A1A2E),
            ],
          ),
          border: Border(
            left: BorderSide(
                color: Color(0xFFFF9A76).withValues(alpha: 0.4), width: 2),
            right: BorderSide(
                color: Color(0xFFFF9A76).withValues(alpha: 0.4), width: 2),
          ),
        ),
        child: Stack(
          children: [
            // Lane dividers
            Row(
              children: [
                Expanded(child: Container()),
                Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.08)),
                Expanded(child: Container()),
                Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.08)),
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
    );
  }

  Widget _buildScenery() {
    return AnimatedBuilder(
      animation: _roadScrollCtrl,
      builder: (_, __) {
        return Stack(
          children: [
            // Left palm trees
            Positioned(
              left: 20,
              bottom: -50 + (_roadScrollCtrl.value * 100) % 200,
              child: _buildPalmTree(),
            ),
            Positioned(
              left: 40,
              bottom: 150 + (_roadScrollCtrl.value * 100) % 300,
              child: _buildPalmTree(),
            ),
            // Right palm trees
            Positioned(
              right: 20,
              bottom: 50 + (_roadScrollCtrl.value * 120) % 250,
              child: _buildPalmTree(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPalmTree() {
    return Container(
      width: 30,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green[700]!.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(LucideIcons.treePine, color: Colors.white70, size: 20),
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

        return Positioned(
          bottom: 120 + (_carBounceCtrl.value * 4),
          left: laneX - 35,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
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
                        color: AppColors.gradientStart.withValues(alpha: glowOpacity),
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

    if (obj.type == ObjectType.coin) {
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
    } else {
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
    }
  }

  Widget _buildHUD(GameState state) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  '${state.distance.toStringAsFixed(0)} m',
                  style: AppTypography.body(
                      size: 14, weight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.coins, size: 14, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  '${state.coins}',
                  style: AppTypography.body(
                      size: 14, weight: FontWeight.w700, color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(LucideIcons.gamepad2, color: Colors.white, size: 44),
          )
              .animate()
              .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack)
              .then()
              .shake(duration: 400.ms, hz: 3),
          const SizedBox(height: 24),
          Text(
            'Endless Drive Tunisia',
            style: AppTypography.h1(
                size: 26, weight: FontWeight.w900, color: Colors.white),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Conduis le plus loin possible !\nGagne des bonus pour ta location.',
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 14, color: Colors.white70),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Démarrer la course',
                style: AppTypography.body(
                    size: 16, weight: FontWeight.w800, color: Colors.white),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 600.ms)
              .slideY(begin: 0.3, end: 0, delay: 600.ms),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => context.push('/game-leaderboard'),
            child: Text(
              'Tableau des scores',
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 800.ms),
        ],
      ),
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

    // Body main shape - aerodynamic sports car
    final bodyPath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.85, h * 0.25)
      ..lineTo(w * 0.95, h * 0.45)
      ..lineTo(w * 0.9, h * 0.55)
      ..lineTo(w * 0.9, h * 0.75)
      ..lineTo(w * 0.85, h * 0.85)
      ..lineTo(w * 0.7, h * 0.9)
      ..lineTo(w * 0.3, h * 0.9)
      ..lineTo(w * 0.15, h * 0.85)
      ..lineTo(w * 0.1, h * 0.75)
      ..lineTo(w * 0.1, h * 0.55)
      ..lineTo(w * 0.05, h * 0.45)
      ..lineTo(w * 0.15, h * 0.25)
      ..close();

    // Body gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gradientStart,
          AppColors.gradientEnd,
          AppColors.gradientStart.withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, bodyPaint);

    // Body outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bodyPath, outlinePaint);

    // Windshield
    final windshieldPath = Path()
      ..moveTo(w * 0.35, h * 0.22)
      ..lineTo(w * 0.65, h * 0.22)
      ..lineTo(w * 0.75, h * 0.38)
      ..lineTo(w * 0.25, h * 0.38)
      ..close();

    final windshieldPaint = Paint()
      ..color = Color(0xFF1A1A3E).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(windshieldPath, windshieldPaint);

    // Windshield reflection
    final reflectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.38, h * 0.26),
      Offset(w * 0.55, h * 0.26),
      reflectionPaint,
    );

    // Headlights (front)
    final headlightLeft = Rect.fromLTWH(w * 0.12, h * 0.42, w * 0.15, h * 0.08);
    final headlightRight = Rect.fromLTWH(w * 0.73, h * 0.42, w * 0.15, h * 0.08);

    final headlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9 + pulse * 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(headlightLeft, Radius.circular(4)),
      headlightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headlightRight, Radius.circular(4)),
      headlightPaint,
    );

    // Headlight glow
    final glowPaint = Paint()
      ..color = Color(0xFFFFE4B5).withValues(alpha: 0.3 + pulse * 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headlightLeft.inflate(4), Radius.circular(6)),
      glowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headlightRight.inflate(4), Radius.circular(6)),
      glowPaint,
    );

    // Taillights (rear)
    final taillightPaint = Paint()
      ..color = Colors.red[400]!.withValues(alpha: 0.8 + pulse * 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.82, w * 0.18, h * 0.04),
        Radius.circular(3),
      ),
      taillightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.67, h * 0.82, w * 0.18, h * 0.04),
        Radius.circular(3),
      ),
      taillightPaint,
    );

    // Spoiler
    final spoilerPaint = Paint()
      ..color = AppColors.gradientEnd.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final spoilerPath = Path()
      ..moveTo(w * 0.2, h * 0.88)
      ..lineTo(w * 0.15, h * 0.95)
      ..lineTo(w * 0.85, h * 0.95)
      ..lineTo(w * 0.8, h * 0.88)
      ..close();
    canvas.drawPath(spoilerPath, spoilerPaint);

    // Side mirrors
    final mirrorPaint = Paint()
      ..color = AppColors.gradientEnd.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.38, w * 0.08, h * 0.06),
        Radius.circular(3),
      ),
      mirrorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.9, h * 0.38, w * 0.08, h * 0.06),
        Radius.circular(3),
      ),
      mirrorPaint,
    );

    // Wheels
    final wheelPaint = Paint()
      ..color = Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // Left wheel
    canvas.drawCircle(Offset(w * 0.22, h * 0.78), w * 0.1, wheelPaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.78), w * 0.05, rimPaint);

    // Right wheel
    canvas.drawCircle(Offset(w * 0.78, h * 0.78), w * 0.1, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.78), w * 0.05, rimPaint);

    // Racing stripe on hood
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.5, h * 0.1),
      Offset(w * 0.5, h * 0.35),
      stripePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SportsCarPainter oldDelegate) {
    return oldDelegate.speedFactor != speedFactor || oldDelegate.pulse != pulse;
  }
}
