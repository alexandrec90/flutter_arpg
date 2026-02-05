import 'package:flame/components.dart';

/// Small interface used by components to call game-level actions
abstract class GameActions {
  void spawnSmear(Vector2 pos, double angle, double size);
  void hitStop();
  void spawnProjectile(Vector2 pos, double angle);
  void reset();
}
