import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import 'package:flutter_arpg/game_actions.dart';
import 'package:flutter_arpg/components/player_component.dart';
import 'package:flutter_arpg/config/constants.dart';
import 'package:flutter_arpg/config/input_bindings.dart';
import 'package:flutter_arpg/components/enemy_component.dart';
import 'package:flutter_arpg/components/projectile_component.dart';
import 'package:flutter_arpg/components/smear_component.dart';

class ARPGGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks
    implements GameActions {
  late PlayerComponent player;
  final InputBindings inputBindings = InputBindings.defaultBindings;
  final double worldWidth = GameConstants.worldWidth;
  final double worldHeight = GameConstants.worldHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerComponent(
      GameConstants.playerStartPosition.clone(),
      inputBindings: inputBindings,
    );
    world.add(player);

    // Center viewfinder anchor and keep camera within world bounds
    camera.viewfinder.anchor = Anchor.center;
    // Snap camera to player's position once on load (prevents a visible jump on first frame)
    camera.viewfinder.position.setFrom(player.position);
    camera.setBounds(
      Rectangle.fromLTWH(0, 0, worldWidth, worldHeight),
      considerViewport: true,
    );
    // Smoothly follow the player using Flame's follow API
    camera.follow(player, maxSpeed: CameraConstants.followMaxSpeed);

    // Simple enemies
    for (final pos in GameConstants.defaultEnemyPositions) {
      world.add(EnemyComponent(position: pos.clone()));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Snap camera to player immediately so resizing never decenters the view
    if (isMounted) {
      camera.viewfinder.position.setFrom(player.position);
    }
  }

  @override
  void spawnProjectile(Vector2 pos, double angle) {
    world.add(ProjectileComponent(pos, angle));
  }

  @override
  void spawnSmear(Vector2 pos, double angle, double size) {
    world.add(SmearComponent(pos, angle, size));
  }

  @override
  void hitStop() {
    pauseEngine();
    Future.delayed(
      Duration(milliseconds: GameConstants.hitStopMs),
      () => resumeEngine(),
    );
  }

  @override
  void reset() {
    world.children
        .whereType<EnemyComponent>()
        .forEach((e) => e.removeFromParent());
    world.children
        .whereType<ProjectileComponent>()
        .forEach((p) => p.removeFromParent());
    world.children
        .whereType<SmearComponent>()
        .forEach((s) => s.removeFromParent());
    player.position.setFrom(GameConstants.playerStartPosition);
    player.health = PlayerConstants.initialHealth;
    // Snap camera to player's position after reset to avoid lag between player and camera
    camera.viewfinder.position.setFrom(player.position);
    for (final pos in GameConstants.defaultEnemyPositions) {
      world.add(EnemyComponent(position: pos.clone()));
    }
  }
}
