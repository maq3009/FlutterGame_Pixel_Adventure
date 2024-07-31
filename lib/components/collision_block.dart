import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  bool isOneWay;
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
    this.isOneWay = true,
  });
}
