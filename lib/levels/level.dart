import 'package:flame/components.dart';
import 'dart:async';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';



class Level extends World {
  
  final String levelName;
  Level({required this.levelName});
  late TiledComponent level;




  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    
    for(final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          final player = Player(  //This brings in the player from the place that you put him in Tiled
            character: 'Mask Dude',
            position: Vector2(spawnPoint.x, spawnPoint.y),
          );
          add(player);
          break;
          default:
      
      }
    }

    // add(Player(character: 'Mask Dude',
    // ),
  



    return super.onLoad();
  }


}