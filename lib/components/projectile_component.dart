import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'enemy_component.dart';
import 'package:flutter_arpg/game_actions.dart';
import 'package:flutter_arpg/config/constants.dart';

class ProjectileComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  final Vector2 velocity;
  final double damage;

  ProjectileComponent(
    Vector2 start,
    double angle, {
    this.damage = ProjectileConstants.damage,
  }) : velocity = Vector2(cos(angle), sin(angle)) * ProjectileConstants.speed,
       super(
         position: start,
         size: Vector2.all(ProjectileConstants.size),
         anchor: Anchor.center,
       );

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    final enemies = game.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      final dist = enemy.position.distanceTo(position);
      if (dist < (enemy.size.x / 2 + size.x / 2)) {
        final dir = enemy.position - position;
        final knock = dir.normalized() * ProjectileConstants.knockback;
        enemy.takeDamage(damage, knock);
        if (game is GameActions) {
          (game as GameActions).spawnSmear(
            enemy.position.clone(),
            atan2(velocity.y, velocity.x),
            ProjectileConstants.smearSize,
          );
          (game as GameActions).hitStop();
        }
        removeFromParent();
        return;
      }
    }

    if (position.x < -ProjectileConstants.outOfBoundsOffset ||
        position.x > (game.size.x + ProjectileConstants.outOfBoundsOffset) ||
        position.y < -ProjectileConstants.outOfBoundsOffset ||
        position.y > (game.size.y + ProjectileConstants.outOfBoundsOffset)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, size.x / 2, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = ProjectileConstants.strokeWidth,
    );
  }
}
