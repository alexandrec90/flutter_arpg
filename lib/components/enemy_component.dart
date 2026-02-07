import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'player_component.dart';
import 'package:flutter_arpg/config/constants.dart';

class EnemyComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  double health = EnemyConstants.health;
  double speed = EnemyConstants.speed;
  final Paint fill = Paint()..color = EnemyConstants.fillColor;
  final Paint stroke = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = EnemyConstants.strokeWidth;

  EnemyComponent({Vector2? position})
    : super(
        position: position ?? Vector2.zero(),
        size: Vector2.all(EnemyConstants.size),
        anchor: Anchor.center,
      );

  @override
  void update(double dt) {
    super.update(dt);
    final players = game.world.children.whereType<PlayerComponent>();
    if (players.isEmpty) return;
    final player = players.first;

    // Move toward player
    final dir = player.position - position;
    if (dir.length > 0) {
      dir.normalize();
      position += dir * speed * dt;
    }

    // Separate from player
    final playerDiff = position - player.position;
    final playerDist = playerDiff.length;
    final playerMinDist = PlayerConstants.collisionRadius + size.x / 2;
    if (playerDist < playerMinDist && playerDist > 0) {
      position += playerDiff.normalized() * ((playerMinDist - playerDist) / 2);
    }

    // Separate from other enemies
    final enemies = game.world.children.whereType<EnemyComponent>();
    for (final other in enemies) {
      if (other == this) continue;
      final diff = position - other.position;
      final dist = diff.length;
      final minDist = size.x; // radius + radius
      if (dist < minDist && dist > 0) {
        position += diff.normalized() * ((minDist - dist) / 2);
      }
    }
  }

  void takeDamage(double dmg, Vector2 knockback) {
    health -= dmg;
    position += knockback;
    if (health <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, size.x / 2, fill);
    canvas.drawCircle(Offset.zero, size.x / 2, stroke);
  }
}
