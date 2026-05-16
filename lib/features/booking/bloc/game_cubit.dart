import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_repository.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final GameRepository _repository;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();
  bool _hasSavedSession = false;
  bool _statsLoaded = false;

  // Timers are ticked every 50ms => 20 ticks per second
  static const double _tickSeconds = 0.05;

  GameCubit() : _repository = GameRepository(), super(const GameState()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (_statsLoaded) return;
    _statsLoaded = true;
    final best = await _repository.getBestDistance();
    final total = await _repository.getTotalCoins();
    final played = await _repository.getGamesPlayed();
    emit(state.copyWith(
      bestDistance: best,
      totalCoins: total,
      gamesPlayed: played,
    ));
  }

  Future<void> startGame() async {
    await _loadStats();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _hasSavedSession = false;

    await _repository.incrementGamesPlayed();

    emit(GameState(
      bestDistance: state.bestDistance,
      totalCoins: state.totalCoins,
      gamesPlayed: state.gamesPlayed + 1,
      gameStarted: true,
      gameOver: false,
      agencyConfirmed: false,
      distance: 0,
      coins: 0,
      lane: 1,
      speed: 8.0,
      objects: const [],
      hasShield: false,
      hasMagnet: false,
      coinMultiplier: 1,
      boostTimeLeft: 0,
      magnetTimeLeft: 0,
      multiplierTimeLeft: 0,
      level: 1,
      bestSpeed: 8.0,
    ));

    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _update(),
    );

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => _spawnObject(),
    );
  }

  void _update() {
    if (!state.gameStarted || state.gameOver) return;

    // Decrement power-up timers
    var newBoostTime = (state.boostTimeLeft - _tickSeconds).clamp(0.0, 999.0);
    var newMagnetTime = (state.magnetTimeLeft - _tickSeconds).clamp(0.0, 999.0);
    var newMultiplierTime = (state.multiplierTimeLeft - _tickSeconds).clamp(0.0, 999.0);

    // Base speed grows with distance and level
    final newDistance = state.distance + state.speed;
    final level = 1 + (newDistance / 2000).floor();
    final baseSpeed = 8.0 + (newDistance / 2000) * 1.5 + (level * 0.5);
    var newSpeed = baseSpeed.clamp(5.0, 35.0);

    // Nitro speed boost
    if (newBoostTime > 0) {
      newSpeed *= 1.6;
    }

    // Best speed tracking
    final bestSpeed = newSpeed > state.bestSpeed ? newSpeed : state.bestSpeed;

    var newObjects = state.objects
        .map((o) => o.copyWith(y: o.y + newSpeed * 2))
        .toList();
    newObjects.removeWhere((o) => o.y > 950);

    var newCoins = state.coins;
    const carY = 650.0;
    final toRemove = <GameObject>[];

    // Magnet range (adjacent lanes)
    final magnetLanes = state.hasMagnet && newMagnetTime > 0
        ? {state.lane - 1, state.lane, state.lane + 1}
            .where((l) => l >= 0 && l <= 2)
            .toSet()
        : <int>{state.lane};

    bool shieldLost = false;
    int newCoinMultiplier = state.coinMultiplier;

    for (var obj in newObjects) {
      if (magnetLanes.contains(obj.lane)) {
        final dy = (obj.y - carY).abs();
        if (dy < 60) {
          switch (obj.type) {
            case ObjectType.coin:
              newCoins += 10 * newCoinMultiplier;
              HapticFeedback.lightImpact();
              toRemove.add(obj);
              break;
            case ObjectType.speedBoost:
              newBoostTime = 4.0;
              HapticFeedback.mediumImpact();
              toRemove.add(obj);
              break;
            case ObjectType.shield:
              HapticFeedback.mediumImpact();
              toRemove.add(obj);
              break;
            case ObjectType.magnet:
              newMagnetTime = 6.0;
              HapticFeedback.mediumImpact();
              toRemove.add(obj);
              break;
            case ObjectType.coinMultiplier:
              newMultiplierTime = 6.0;
              newCoinMultiplier = 2;
              HapticFeedback.mediumImpact();
              toRemove.add(obj);
              break;
            case ObjectType.obstacle:
              if (state.hasShield && newBoostTime <= 0) {
                // Shield absorbs the hit (not during nitro)
                HapticFeedback.heavyImpact();
                toRemove.add(obj);
                shieldLost = true;
              } else if (newBoostTime > 0) {
                // Nitro destroys obstacle
                HapticFeedback.heavyImpact();
                toRemove.add(obj);
              } else {
                newSpeed = (newSpeed * 0.6).clamp(5.0, 35.0);
                HapticFeedback.heavyImpact();
                toRemove.add(obj);
              }
              break;
          }
        }
      }
    }

    newObjects.removeWhere((o) => toRemove.contains(o));

    if (newMultiplierTime <= 0) {
      newCoinMultiplier = 1;
    }

    final gainedShield = toRemove.any((o) => o.type == ObjectType.shield);
    final hasShield = (!shieldLost && state.hasShield) || gainedShield;
    final hasMagnet = newMagnetTime > 0;

    emit(state.copyWith(
      distance: newDistance,
      speed: newSpeed,
      coins: newCoins,
      objects: newObjects,
      level: level,
      bestSpeed: bestSpeed,
      hasShield: hasShield,
      hasMagnet: hasMagnet,
      coinMultiplier: newCoinMultiplier,
      boostTimeLeft: newBoostTime,
      magnetTimeLeft: newMagnetTime,
      multiplierTimeLeft: newMultiplierTime,
    ));
  }

  void _spawnObject() {
    if (!state.gameStarted || state.gameOver) return;

    final lane = _random.nextInt(3);
    final roll = _random.nextDouble();

    ObjectType type;
    if (roll < 0.40) {
      type = ObjectType.coin;
    } else if (roll < 0.65) {
      type = ObjectType.obstacle;
    } else if (roll < 0.78) {
      type = ObjectType.speedBoost;
    } else if (roll < 0.86) {
      type = ObjectType.shield;
    } else if (roll < 0.93) {
      type = ObjectType.magnet;
    } else {
      type = ObjectType.coinMultiplier;
    }

    final newObject = GameObject(
      lane: lane,
      y: -100.0,
      type: type,
    );

    emit(state.copyWith(objects: [...state.objects, newObject]));
  }

  void moveLane(int direction) {
    if (!state.gameStarted || state.gameOver) return;
    HapticFeedback.selectionClick();
    final newLane = (state.lane + direction).clamp(0, 2);
    emit(state.copyWith(lane: newLane));
  }

  Future<void> endGame() async {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    if (_hasSavedSession) {
      if (!state.gameOver) {
        emit(state.copyWith(gameOver: true));
      }
      return;
    }
    _hasSavedSession = true;

    await _loadStats();

    final currentDistance = state.distance.toInt();
    final currentCoins = state.coins;

    if (currentDistance > state.bestDistance) {
      await _repository.saveBestDistance(currentDistance);
    }
    await _repository.addTotalCoins(currentCoins);

    emit(state.copyWith(
      gameOver: true,
      bestDistance: currentDistance > state.bestDistance
          ? currentDistance
          : state.bestDistance,
      totalCoins: state.totalCoins + currentCoins,
    ));
  }

  Future<void> agencyConfirm() async {
    await endGame();
    emit(state.copyWith(agencyConfirmed: true));
  }

  void prepareNewGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _hasSavedSession = false;
    emit(GameState(
      bestDistance: state.bestDistance,
      totalCoins: state.totalCoins,
      gamesPlayed: state.gamesPlayed,
      gameStarted: false,
      gameOver: false,
      agencyConfirmed: state.agencyConfirmed,
      distance: 0,
      coins: 0,
      lane: 1,
      speed: 8.0,
      objects: const [],
      hasShield: false,
      hasMagnet: false,
      coinMultiplier: 1,
      boostTimeLeft: 0,
      magnetTimeLeft: 0,
      multiplierTimeLeft: 0,
      level: 1,
      bestSpeed: 8.0,
    ));
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    return super.close();
  }
}
