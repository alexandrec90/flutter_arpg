import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Centralized game constants to avoid hard-coded values across the codebase.
class GameConstants {
  static const double worldWidth = 2000.0;
  static const double worldHeight = 2000.0;

  // Initial player start position (not const so we provide a getter clone where needed)
  static Vector2 get playerStartPosition => Vector2(400, 300);

  static List<Vector2> get defaultEnemyPositions => [
    Vector2(200, 200),
    Vector2(600, 200),
    Vector2(400, 500),
  ];

  /// Hit-stop duration in milliseconds
  static const int hitStopMs = 50;
}

class CameraConstants {
  // Camera follow max speed in pixels per second
  static const double followMaxSpeed = 600.0;
}

class PlayerConstants {
  static const double speed = 180.0; // pixels/s
  static const double dashDuration = 0.12; // seconds
  static const double dashVelocity = 550.0; // pixels/s
  static const double initialHealth = 100.0;
  static Vector2 get size => Vector2(32, 40);
  static const double cornerRadius = 6.0;
  static const double strokeWidth = 4.0;
  static const Color fillColor = Color(0xFF3EE3A5);
  static const double collisionRadius = 18.0;
  static const double hitKnockback = 25.0; // pixels (instant displacement)
  static const double hitInvincibilityDuration = 0.5; // seconds
}

class EnemyConstants {
  static const double health = 30.0;
  static const double speed = 70.0;
  static const double size = 30.0;
  static const double strokeWidth = 3.0;
  static const Color fillColor = Colors.red;
  static const double contactDamage = 10.0;
}

class ProjectileConstants {
  static const double damage = 15.0;
  static const double speed = 700.0; // pixels/s
  static const double size = 8.0;
  static const double knockback = 20.0;
  static const double smearSize = 48.0;
  static const double outOfBoundsOffset = 200.0;
  static const double strokeWidth = 2.0;
}

class SmearConstants {
  // 2 frames at 60 fps
  static const double life = 2.0 / 60.0;
  static const double perpMul = 0.4;
  static const double strokeWidth = 2.0;
}
