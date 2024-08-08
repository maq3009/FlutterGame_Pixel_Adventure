installed flutter pub add flame
installed flutter pub add flame_tiled



import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'dart:async';



enum CustomJoystickDirection {
  left, right, idle,
}

enum PlayerState {
  running, idle
}
class PixelAdventure extends FlameGame
  with
    HasKeyboardHandlerComponents,
    DragCallbacks,
    HasCollisionDetection,
    TapCallbacks {
  CustomJoystickDirection joystickDirection = CustomJoystickDirection.idle;
  
  
  @override
  Color backgroundColor() => const Color(0x0f211f30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true;
  bool playSounds = true;
  bool isFacingRight = true;
  double horizontalMovement = 0;
  double soundVolume = 1.0; 
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
    _updateJoystick();
    _updatePlayerMovement(dt);
    super.update(dt);
  }


  void _loadLevel() {
    Future.delayed(const Duration(milliseconds: 100), () {
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



 void _updatePlayerMovement(double dt) {
    // Apply horizontal movement
    player.position.x += horizontalMovement * player.moveSpeed * dt;
  }


  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 60),
      priority: 100,
    );
    add(joystick);
    add(JumpButton());
  }



  void loadNextLevel() {
    if(currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {  //no more levels, you're at the last level
      // currentLevelIndex = 0;

    }
  }


void _updateJoystick() {
    if (joystick.relativeDelta.x < -0.1) {
      joystickDirection = CustomJoystickDirection.left;
    } else if (joystick.relativeDelta.x > 0.1) {
      joystickDirection = CustomJoystickDirection.right;
    } else {
      joystickDirection = CustomJoystickDirection.idle;
    }

    switch (joystickDirection) {
      case CustomJoystickDirection.left:
        horizontalMovement = -1.0;
        if (isFacingRight) {
          player.flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        player.current = PlayerState.running;
        break;
      case CustomJoystickDirection.right:
        horizontalMovement = 1.0;
        if (!isFacingRight) {
          player.flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        player.current = PlayerState.running;
        break;
      case CustomJoystickDirection.idle:
        horizontalMovement = 0.0;
        player.current = PlayerState.idle;
        break;
    }
}



}