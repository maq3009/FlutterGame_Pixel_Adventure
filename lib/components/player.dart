import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';


enum PlayerState {idle, running, jumping, falling}

enum PlayerDirection {
  left, right, none,
}


class Player extends SpriteAnimationGroupComponent
 with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({super.position, this.character = 'Ninja Frog'});



  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation jumpingAnimation;
  
  final double stepTime = 0.05;
  final double keyboardMoveSpeed = 0.5;
  final double _gravity = 9.8;
  final double _jumpForce = 350;
  final double _terminalVelocity = 100;

  PlayerDirection playerDirection = PlayerDirection.none;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool isFacingRight = true;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitBox hitbox = CustomHitBox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetY, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA)  || 
      keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD)  || 
      keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);


  return super.onKeyEvent(event, keysPressed);
 }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) other.collidedWithPlayer();
    
    
    super.onCollision(intersectionPoints, other);
  }


  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    
    
    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
      );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if(velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if(velocity.y > 0) playerState = PlayerState.falling;

    if(velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }


void _updatePlayerMovement(double dt) {
  // Determine horizontal movement based on playerDirection
  switch (playerDirection) {
    case PlayerDirection.left:
      horizontalMovement = -1.0;
      if (isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      }
      current = PlayerState.running;
      break;
    case PlayerDirection.right:
      horizontalMovement = 1.0;
      if (!isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }
      current = PlayerState.running;
      break;
    case PlayerDirection.none:
      horizontalMovement = 0.0;
      current = PlayerState.idle;
      break;
  }

  // Calculate velocity based on horizontal movement and move speed
  velocity.x = horizontalMovement * moveSpeed;

  // Apply velocity to position, scaled by delta time
  position.x += velocity.x * dt;

  // Handle jumping if necessary
  if (hasJumped && isOnGround) _playerJump(dt);
}

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
  
  void _checkHorizontalCollisions() {
    for(final block in collisionBlocks) {
      if(!block.isPlatform) {
        if(checkCollision(this, block)) {
          if(velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
        
          }
          if(velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
    
          }
        }
      }
    }
  }
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for(final block in collisionBlocks) {
      if(!block.isPlatform  || block.isOneWay) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.position.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
      } else if (block.isOneWay) {
          if(velocity.y > 0 && position.y + hitbox.height <= block.position.y + block.size.y) {
            velocity.y = 0;
            position.y = block.position.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = block.position.y + block.size.y - hitbox.offsetY;
        }
      }
        
      }else {
        if(checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.position.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.position.y + block.height - hitbox.offsetY;
          }
        }
      }
      }
    }
  }
}

