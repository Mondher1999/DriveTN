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
    ));

    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _update(),
    );

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: 1200),
      (_) => _spawnObject(),
    );
  }

  void _update() {
    if (!state.gameStarted || state.gameOver) return;

    var newDistance = state.distance + state.speed;
    var newSpeed = 8.0 + (newDistance / 5000);

    var newObjects = state.objects
        .map((o) => o.copyWith(y: o.y + newSpeed * 2))
        .toList();
    newObjects.removeWhere((o) => o.y > 900);

    var newCoins = state.coins;
    const carY = 650.0;
    final toRemove = <GameObject>[];

    for (var obj in newObjects) {
      if (obj.lane == state.lane) {
        final dy = (obj.y - carY).abs();
        if (dy < 60) {
          if (obj.type == ObjectType.coin) {
            newCoins += 10;
            HapticFeedback.lightImpact();
            toRemove.add(obj);
          } else {
            newSpeed = (newSpeed * 0.7).clamp(5.0, 20.0);
            HapticFeedback.heavyImpact();
            toRemove.add(obj);
          }
        }
      }
    }

    newObjects.removeWhere((o) => toRemove.contains(o));

    emit(state.copyWith(
      distance: newDistance,
      speed: newSpeed,
      coins: newCoins,
      objects: newObjects,
    ));
  }

  void _spawnObject() {
    if (!state.gameStarted || state.gameOver) return;

    final lane = _random.nextInt(3);
    final isCoin = _random.nextDouble() < 0.4;

    final newObject = GameObject(
      lane: lane,
      y: -100.0,
      type: isCoin ? ObjectType.coin : ObjectType.obstacle,
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
    ));
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    return super.close();
  }
}
