enum ObjectType { coin, obstacle }

class GameObject {
  final int lane;
  double y;
  final ObjectType type;

  GameObject({required this.lane, required this.y, required this.type});
}
