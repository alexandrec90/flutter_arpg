import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_arpg/game_actions.dart';
import 'package:flutter_arpg/config/constants.dart';

class PlayerComponent extends PositionComponent
    with KeyboardHandler, HasGameReference<FlameGame> {
  Vector2 velocity = Vector2.zero();
  final double speed = PlayerConstants.speed; // pixels per second
  bool dashing = false;
  double dashTime = 0.0;
  final double dashDuration = PlayerConstants.dashDuration;
  double health = PlayerConstants.initialHealth;

  PlayerComponent(Vector2 pos)
    : super(
        position: pos,
        size: PlayerConstants.size.clone(),
        anchor: Anchor.center,
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (dashing) {
      dashTime += dt;
      if (dashTime >= dashDuration) {
        dashing = false;
        dashTime = 0.0;
        scale.y = 1.2; // landing squash briefly
      }
    }

    // apply velocity
    position += velocity * dt;

    // Smooth scale back toward 1.0
    scale += (Vector2.all(1.0) - scale) * (dt * 10);

    // if moving, apply stretch
    final spd = velocity.length;
    final stretchFactor = (spd / speed).clamp(0.0, 1.0);
    scale.x = 1.0 + (stretchFactor * 0.45) * (dashing ? 1.4 : 1.0);
    scale.y = 1.0 - (stretchFactor * 0.3);

    // Keep inside reasonable bounds (if available)
    if (game.size.x > 0 && game.size.y > 0) {
      position.clamp(
        Vector2.zero() + size / 2,
        Vector2(game.size.x, game.size.y) - size / 2,
      );
    }
  }

  void dash() {
    if (dashing) return;
    Vector2 dir = velocity.clone();
    if (dir.length == 0) dir = Vector2(1, 0);
    dir.normalize();
    velocity = dir * PlayerConstants.dashVelocity;
    dashing = true;
    dashTime = 0.0;
  }

  void attackTo(Vector2 worldTarget) {
    if (game is GameActions) {
      (game as GameActions).spawnProjectile(
        position.clone(),
        atan2(worldTarget.y - position.y, worldTarget.x - position.x),
      );
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final dir = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) dir.y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) dir.y += 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) dir.x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) dir.x += 1;
    if (dir.length > 0) {
      dir.normalize();
      velocity = dir * speed;
    } else {
      if (!dashing) velocity = Vector2.zero();
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      dash();
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
      if (game is GameActions) (game as GameActions).reset();
    }
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      Radius.circular(PlayerConstants.cornerRadius),
    );
    canvas.drawRRect(r, Paint()..color = PlayerConstants.fillColor);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = PlayerConstants.strokeWidth,
    );
  }
}
