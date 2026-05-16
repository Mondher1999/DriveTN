import 'package:equatable/equatable.dart';

enum ObjectType { coin, obstacle, speedBoost, shield, magnet, coinMultiplier }

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

  // Power-ups
  final bool hasShield;
  final bool hasMagnet;
  final int coinMultiplier;
  final double boostTimeLeft;
  final double magnetTimeLeft;
  final double multiplierTimeLeft;

  // Progression
  final int level;
  final double bestSpeed;

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
    this.hasShield = false,
    this.hasMagnet = false,
    this.coinMultiplier = 1,
    this.boostTimeLeft = 0,
    this.magnetTimeLeft = 0,
    this.multiplierTimeLeft = 0,
    this.level = 1,
    this.bestSpeed = 8.0,
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
    bool? hasShield,
    bool? hasMagnet,
    int? coinMultiplier,
    double? boostTimeLeft,
    double? magnetTimeLeft,
    double? multiplierTimeLeft,
    int? level,
    double? bestSpeed,
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
      hasShield: hasShield ?? this.hasShield,
      hasMagnet: hasMagnet ?? this.hasMagnet,
      coinMultiplier: coinMultiplier ?? this.coinMultiplier,
      boostTimeLeft: boostTimeLeft ?? this.boostTimeLeft,
      magnetTimeLeft: magnetTimeLeft ?? this.magnetTimeLeft,
      multiplierTimeLeft: multiplierTimeLeft ?? this.multiplierTimeLeft,
      level: level ?? this.level,
      bestSpeed: bestSpeed ?? this.bestSpeed,
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
        hasShield,
        hasMagnet,
        coinMultiplier,
        boostTimeLeft,
        magnetTimeLeft,
        multiplierTimeLeft,
        level,
        bestSpeed,
      ];
}
