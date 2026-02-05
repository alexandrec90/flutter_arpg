import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';

import 'package:flutter_arpg/game_actions.dart';
import 'package:flutter_arpg/components/player_component.dart';
import 'package:flutter_arpg/config/constants.dart';
import 'package:flutter_arpg/components/enemy_component.dart';
import 'package:flutter_arpg/components/projectile_component.dart';
import 'package:flutter_arpg/components/smear_component.dart';

class ARPGGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks
    implements GameActions {
  late PlayerComponent player;
  final double worldWidth = GameConstants.worldWidth;
  final double worldHeight = GameConstants.worldHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerComponent(GameConstants.playerStartPosition.clone());
    add(player);

    // Camera follow removed: update here if you opt into newer Flame camera API.

    // Simple enemies
    for (final pos in GameConstants.defaultEnemyPositions) {
      add(EnemyComponent(position: pos.clone()));
    }
  }

  @override
  void spawnProjectile(Vector2 pos, double angle) {
    add(ProjectileComponent(pos, angle));
  }

  @override
  void spawnSmear(Vector2 pos, double angle, double size) {
    add(SmearComponent(pos, angle, size));
  }

  @override
  void hitStop() {
    pauseEngine();
    Future.delayed(Duration(milliseconds: GameConstants.hitStopMs), () => resumeEngine());
  }

  @override
  void reset() {
    children.whereType<EnemyComponent>().forEach((e) => e.removeFromParent());
    children.whereType<ProjectileComponent>().forEach(
      (p) => p.removeFromParent(),
    );
    children.whereType<SmearComponent>().forEach((s) => s.removeFromParent());
    player.position.setFrom(GameConstants.playerStartPosition);
    player.health = PlayerConstants.initialHealth;
    for (final pos in GameConstants.defaultEnemyPositions) {
      add(EnemyComponent(position: pos.clone()));
    }
  }
}
