import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<PixelAdventure>{
  // ignore: use_super_parameters
  Checkpoint({position, size,
  }) : super(
    position: position,
    size: size,
  );


  @override
  FutureOr<void> onLoad() {
    priority = 1;
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'), SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 0.05,
      textureSize: Vector2.all(64),
    ));
    return super.onLoad();
  }
}