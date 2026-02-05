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
    final players = game.children.whereType<PlayerComponent>();
    if (players.isEmpty) return;
    final player = players.first;
    final dir = player.position - position;
    if (dir.length > 0) {
      dir.normalize();
      position += dir * speed * dt;
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
