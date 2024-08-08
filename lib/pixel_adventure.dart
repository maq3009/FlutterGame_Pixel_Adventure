import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';
import 'dart:async';


enum CustomJoystickDirection {
  left, right, idle,
}



class PixelAdventure extends FlameGame
  with
    HasKeyboardHandlerComponents,
    DragCallbacks,
    HasCollisionDetection,
    TapCallbacks {
  double horizontalMovement = 0;
  CustomJoystickDirection joystickDirection = CustomJoystickDirection.idle;
  @override
  Color backgroundColor() => const Color(0x0f211f30);
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true;
  bool isFacingRight = true;
  bool playSounds = true;
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

 void _updatePlayerMovement(double dt) {
    // Apply horizontal movement
    player.position.x += horizontalMovement * player.moveSpeed * dt;
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
      margin: const EdgeInsets.only(left:40, bottom: 40),
      priority: 100,
      
    );
    add(joystick);
    add(JumpButton());
  }

void _updateJoystick() {
    if (joystick.relativeDelta.x < -0.1) {
      horizontalMovement = -1;
      joystickDirection = CustomJoystickDirection.left;
    } else if (joystick.relativeDelta.x > 0.1) {
      horizontalMovement = 1;
      joystickDirection = CustomJoystickDirection.right;
    } else {
      joystickDirection = CustomJoystickDirection.idle;
      horizontalMovement = 0;
    }


}

  void loadNextLevel() {
    if(currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {  //no more levels, you're at the last level
      // currentLevelIndex = 0;
      // _loadLevel();
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

