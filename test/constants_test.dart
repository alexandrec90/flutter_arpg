import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_arpg/config/constants.dart';

void main() {
  group('GameConstants', () {
    test('world dimensions are positive', () {
      expect(GameConstants.worldWidth, greaterThan(0));
      expect(GameConstants.worldHeight, greaterThan(0));
    });

    test('playerStartPosition returns a fresh instance each call', () {
      final a = GameConstants.playerStartPosition;
      final b = GameConstants.playerStartPosition;
      expect(a, equals(b));
      a.x = -1;
      expect(b.x, isNot(-1), reason: 'getter should return independent copies');
    });

    test('defaultEnemyPositions returns independent copies', () {
      final a = GameConstants.defaultEnemyPositions;
      final b = GameConstants.defaultEnemyPositions;
      a[0].x = -999;
      expect(b[0].x, isNot(-999));
    });

    test('hitStopMs is positive', () {
      expect(GameConstants.hitStopMs, greaterThan(0));
    });
  });

  group('PlayerConstants', () {
    test('speed is positive', () {
      expect(PlayerConstants.speed, greaterThan(0));
    });

    test('initialHealth is positive', () {
      expect(PlayerConstants.initialHealth, greaterThan(0));
    });

    test('dash values are positive', () {
      expect(PlayerConstants.dashDuration, greaterThan(0));
      expect(PlayerConstants.dashVelocity, greaterThan(0));
    });
  });

  group('EnemyConstants', () {
    test('health and speed are positive', () {
      expect(EnemyConstants.health, greaterThan(0));
      expect(EnemyConstants.speed, greaterThan(0));
    });
  });

  group('ProjectileConstants', () {
    test('damage and speed are positive', () {
      expect(ProjectileConstants.damage, greaterThan(0));
      expect(ProjectileConstants.speed, greaterThan(0));
    });
  });

  group('CameraConstants', () {
    test('follow speed is positive', () {
      expect(CameraConstants.followMaxSpeed, greaterThan(0));
    });
  });
}
