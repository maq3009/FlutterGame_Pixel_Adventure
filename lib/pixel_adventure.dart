import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'dart:async';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0x0f211f30);
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true;


  @override
  FutureOr<void> onLoad() async {
    //Load all images into the cache
    await images.loadAllImages();
  
  @override
  final world = Level(
    player: player,
    levelName: 'Level-01');


    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    cam.priority = 1;

    addAll([cam, world]);

    if(showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    _updatePlayerMovement();
    super.update(dt);
  }

      void _updatePlayerMovement() {
    if (joystick.direction == JoystickDirection.idle) {
      player.horizontalMovement = 0;  // No joystick movement, check keyboard input
    } else {
      switch (joystick.direction) {
        case JoystickDirection.left:
        case JoystickDirection.upLeft:
        case JoystickDirection.downLeft:
          player.horizontalMovement = -1;
          break;
        case JoystickDirection.right:
        case JoystickDirection.upRight:
        case JoystickDirection.downRight:
          player.horizontalMovement = 1;
          break;
        default:
          player.horizontalMovement = 0;
          break;
      }
    }
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left:100, bottom: 100),
      priority: 10000,
      
    );
    add(joystick);
  }

  void updateJoystick() {
    
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
      break;
    }
  }

}