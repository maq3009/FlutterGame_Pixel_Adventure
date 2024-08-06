import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'dart:async';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0x0f211f30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true;
  List<String> levelNames = ['Level-01', 'Level-02', 'Level-03'];
  int currentLevelIndex = 0;
  Level? currentLevel;

  @override
  FutureOr<void> onLoad() async {
    //Load all images into the cache
    await images.loadAllImages();
    priority = 1;


    _loadLevel();

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
      priority: 100,
      
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

  void loadNextLevel() {
    if(currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {  //no more levels, you're at the last level

    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if(currentLevel !=null) {
        remove(currentLevel!);
        remove(cam);
      }
      
      
      Level newLevel = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );


      cam = CameraComponent.withFixedResolution(
        world: newLevel,
        width: 640,
        height: 360);
      cam.viewfinder.anchor = Anchor.topLeft;
      cam.priority = 11;

      currentLevel = newLevel;
      addAll([cam, newLevel]);

    });
  }
}