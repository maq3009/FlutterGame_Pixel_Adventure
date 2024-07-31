import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';





class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure>,
CollisionCallbacks {
  final String fruit;

  Fruit({
    this.fruit = 'Apple',
    Vector2? position,
    Vector2? size,
  }) : super(
          position: position ?? Vector2.zero(),
          size: size ?? Vector2.all(32),
        );

  bool _collected = false;
  final double stepTime = 0.05;
  final hitbox = CustomHitBox(
    offsetX: 8,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  @override
  FutureOr<void> onLoad() async {
    debugMode = true;
    priority = -1;

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType. passive,
    ));



    final image = await gameRef.images.load('Items/Fruits/$fruit.png');
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
  void collidedWithPlayer() {
    if(!_collected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
      _collected = true;
    }
    // removeFromParent();
  }
}
