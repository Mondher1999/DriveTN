import 'package:equatable/equatable.dart';

enum ObjectType { coin, obstacle }

class GameObject extends Equatable {
  final int lane;
  final double y;
  final ObjectType type;

  const GameObject({
    required this.lane,
    required this.y,
    required this.type,
  });

  GameObject copyWith({int? lane, double? y, ObjectType? type}) {
    return GameObject(
      lane: lane ?? this.lane,
      y: y ?? this.y,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [lane, y, type];
}

class GameState extends Equatable {
  final double distance;
  final int coins;
  final int lane;
  final double speed;
  final List<GameObject> objects;
  final bool gameStarted;
  final bool gameOver;
  final bool agencyConfirmed;
  final int bestDistance;
  final int totalCoins;
  final int gamesPlayed;

  const GameState({
    this.distance = 0,
    this.coins = 0,
    this.lane = 1,
    this.speed = 8.0,
    this.objects = const [],
    this.gameStarted = false,
    this.gameOver = false,
    this.agencyConfirmed = false,
    this.bestDistance = 0,
    this.totalCoins = 0,
    this.gamesPlayed = 0,
  });

  GameState copyWith({
    double? distance,
    int? coins,
    int? lane,
    double? speed,
    List<GameObject>? objects,
    bool? gameStarted,
    bool? gameOver,
    bool? agencyConfirmed,
    int? bestDistance,
    int? totalCoins,
    int? gamesPlayed,
  }) {
    return GameState(
      distance: distance ?? this.distance,
      coins: coins ?? this.coins,
      lane: lane ?? this.lane,
      speed: speed ?? this.speed,
      objects: objects ?? this.objects,
      gameStarted: gameStarted ?? this.gameStarted,
      gameOver: gameOver ?? this.gameOver,
      agencyConfirmed: agencyConfirmed ?? this.agencyConfirmed,
      bestDistance: bestDistance ?? this.bestDistance,
      totalCoins: totalCoins ?? this.totalCoins,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        distance,
        coins,
        lane,
        speed,
        objects,
        gameStarted,
        gameOver,
        agencyConfirmed,
        bestDistance,
        totalCoins,
        gamesPlayed,
      ];
}
