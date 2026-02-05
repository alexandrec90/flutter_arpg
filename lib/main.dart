import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2D ARPG Proof of Concept',
      theme: ThemeData(useMaterial3: false),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class Enemy {
  double x;
  double y;
  double health;
  Color color;
  double lastDamageTime = 0.0;
  double deathTime = 0.0;

  Enemy(this.x, this.y, this.health, this.color);

  bool isAlive() => health > 0;
  bool isDead() => health <= 0 && deathTime == 0.0;
}

class Projectile {
  double x;
  double y;
  double vx = 0.0;
  double vy = 0.0;
  double speed = 8.0;

  Projectile(this.x, this.y, double angle) {
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }

  void update() {
    x += vx;
    y += vy;
  }

  bool isOffScreen(
    double screenWidth,
    double screenHeight,
    double cameraX,
    double cameraY,
  ) {
    final screenX = x - cameraX;
    final screenY = y - cameraY;
    return screenX < -50 ||
        screenX > screenWidth + 50 ||
        screenY < -50 ||
        screenY > screenHeight + 50;
  }
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 400.0;
  double playerY = 300.0;
  double playerAngle = 0.0;
  double cameraX = 0.0;
  double cameraY = 0.0;
  double playerHealth = 100.0;
  double lastAttackTime = 0.0;
  double playerLastDamageTime = 0.0;

  final Set<LogicalKeyboardKey> keysPressed = {};
  final double moveSpeed = 3.0;
  Timer? gameLoopTimer;

  List<Enemy> enemies = [
    Enemy(200, 200, 30, Colors.red),
    Enemy(600, 200, 30, Colors.orange),
    Enemy(400, 500, 30, Colors.purple),
  ];

  List<Projectile> projectiles = [];

  double get currentTime => DateTime.now().millisecondsSinceEpoch / 1000.0;

  @override
  void initState() {
    super.initState();
    _startGameLoop();
  }

  void _startGameLoop() {
    gameLoopTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      setState(() {
        // WASD movement
        if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
          playerY -= moveSpeed;
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
          playerY += moveSpeed;
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
          playerX -= moveSpeed;
        }
        if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
          playerX += moveSpeed;
        }

        // Update camera to follow player
        // This will be recalculated in build() based on actual screen size
        // cameraX and cameraY are updated there

        // Update projectiles
        for (var projectile in projectiles) {
          projectile.update();
        }

        // Check projectile-enemy collisions
        for (var projectile in List.from(projectiles)) {
          for (var enemy in enemies) {
            if (!enemy.isAlive()) continue;

            final dx = enemy.x - projectile.x;
            final dy = enemy.y - projectile.y;
            final distance = sqrt(dx * dx + dy * dy);

            if (distance < 25) {
              enemy.health -= 15;
              enemy.lastDamageTime = currentTime;
              projectiles.remove(projectile);

              // Knockback enemy
              if (distance > 0) {
                final knockbackForce = 20.0;
                enemy.x += (dx / distance) * knockbackForce;
                enemy.y += (dy / distance) * knockbackForce;
              }
              break;
            }
          }
        }

        // Remove off-screen projectiles
        projectiles.removeWhere(
          (p) => p.isOffScreen(800, 600, cameraX, cameraY),
        );

        // Enemy AI - move towards player
        for (var enemy in enemies) {
          if (enemy.isAlive()) {
            final dx = playerX - enemy.x;
            final dy = playerY - enemy.y;
            final distance = sqrt(dx * dx + dy * dy);
            if (distance > 0) {
              enemy.x += (dx / distance) * 1.5;
              enemy.y += (dy / distance) * 1.5;
            }
          }
        }

        // Resolve collisions
        _resolvePlayerCollisions();
        _resolveEnemyCollisions();

        // Enemy collision damage - check AFTER collision resolution
        for (var enemy in enemies) {
          if (enemy.isAlive()) {
            final dx = playerX - enemy.x;
            final dy = playerY - enemy.y;
            final distance = sqrt(dx * dx + dy * dy);

            // Enemy collision damage
            if (distance < 40) {
              if (currentTime - playerLastDamageTime > 0.2) {
                playerHealth -= 1.0;
                playerLastDamageTime = currentTime;

                // Knockback player
                if (distance > 0) {
                  final knockbackForce = 20.0;
                  playerX += (dx / distance) * knockbackForce;
                  playerY += (dy / distance) * knockbackForce;
                }
              }
            }
          }
        }

        // Record death time for enemies that just died
        for (var enemy in enemies) {
          if (enemy.isDead()) {
            enemy.deathTime = currentTime;
          }
        }

        // Remove dead enemies after animation completes
        const deathAnimationDuration = 0.3;
        enemies.removeWhere(
          (e) =>
              e.deathTime > 0 &&
              (currentTime - e.deathTime) > deathAnimationDuration,
        );

        // Reset if player dies
        if (playerHealth <= 0) {
          playerHealth = 100;
          playerX = 400;
          playerY = 300;
          projectiles = [];
          enemies = [
            Enemy(200, 200, 30, Colors.red),
            Enemy(600, 200, 30, Colors.orange),
            Enemy(400, 500, 30, Colors.purple),
          ];
        }
      });
    });
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  void _attack() {
    final now = currentTime;
    if (now - lastAttackTime < 0.15) return; // 150ms cooldown for shooting

    lastAttackTime = now;

    // Fire projectile in direction player is facing
    projectiles.add(Projectile(playerX, playerY, playerAngle));
  }

  void _resetGame() {
    setState(() {
      playerX = 400.0;
      playerY = 300.0;
      playerHealth = 100.0;
      playerAngle = 0.0;
      cameraX = 0.0;
      cameraY = 0.0;
      projectiles = [];
      enemies = [
        Enemy(200, 200, 30, Colors.red),
        Enemy(600, 200, 30, Colors.orange),
        Enemy(400, 500, 30, Colors.purple),
      ];
    });
  }

  void _resolvePlayerCollisions() {
    const playerRadius = 20.0;

    for (var enemy in enemies) {
      if (!enemy.isAlive()) continue;

      final dx = playerX - enemy.x;
      final dy = playerY - enemy.y;
      final distance = sqrt(dx * dx + dy * dy);
      final minDistance = playerRadius + 15.0; // Enemy is ~15 radius

      if (distance < minDistance && distance > 0) {
        // Push player away from enemy
        final pushDist = minDistance - distance;
        final pushX = (dx / distance) * pushDist;
        final pushY = (dy / distance) * pushDist;
        playerX += pushX;
        playerY += pushY;
      }
    }
  }

  void _resolveEnemyCollisions() {
    for (int i = 0; i < enemies.length; i++) {
      if (!enemies[i].isAlive()) continue;

      for (int j = i + 1; j < enemies.length; j++) {
        if (!enemies[j].isAlive()) continue;

        final dx = enemies[i].x - enemies[j].x;
        final dy = enemies[i].y - enemies[j].y;
        final distance = sqrt(dx * dx + dy * dy);
        final minDistance = 30.0; // Both are ~15 radius

        if (distance < minDistance && distance > 0) {
          // Push enemies apart
          final pushDist = (minDistance - distance) / 2;
          final pushX = (dx / distance) * pushDist;
          final pushY = (dy / distance) * pushDist;

          enemies[i].x += pushX;
          enemies[i].y += pushY;
          enemies[j].x -= pushX;
          enemies[j].y -= pushY;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Update camera to center on player
    cameraX = playerX - screenWidth / 2;
    cameraY = playerY - screenHeight / 2;

    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: (event) {
          if (event.isKeyPressed(event.logicalKey)) {
            keysPressed.add(event.logicalKey);
            // Check for space bar to attack
            if (event.logicalKey == LogicalKeyboardKey.space) {
              _attack();
            }
            // Check for R to reset
            if (event.logicalKey == LogicalKeyboardKey.keyR) {
              _resetGame();
            }
          } else {
            keysPressed.remove(event.logicalKey);
          }
        },
        child: MouseRegion(
          onHover: (event) {
            final centerX = screenWidth / 2;
            final centerY = screenHeight / 2;

            final dx = event.position.dx - centerX;
            final dy = event.position.dy - centerY;
            playerAngle = atan2(dy, dx);
          },
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                playerAngle = atan2(
                  details.globalPosition.dy - screenHeight / 2,
                  details.globalPosition.dx - screenWidth / 2,
                );
              });
            },
            onTap: _attack,
            child: Container(
              color: Color(0xFF1a1a2e),
              child: CustomPaint(
                painter: GamePainter(
                  playerX: playerX,
                  playerY: playerY,
                  playerAngle: playerAngle,
                  cameraX: cameraX,
                  cameraY: cameraY,
                  playerHealth: playerHealth,
                  playerLastDamageTime: playerLastDamageTime,
                  enemies: enemies,
                  projectiles: projectiles,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double atan2(double y, double x) {
  return atan(y / (x == 0 ? 0.0001 : x)) + (x < 0 ? pi : 0);
}

class GamePainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final double playerAngle;
  final double cameraX;
  final double cameraY;
  final double playerHealth;
  final double playerLastDamageTime;
  final List<Enemy> enemies;
  final List<Projectile> projectiles;
  final double screenWidth;
  final double screenHeight;

  GamePainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.cameraX,
    required this.cameraY,
    required this.playerHealth,
    required this.playerLastDamageTime,
    required this.enemies,
    required this.projectiles,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid
    final gridPaint = Paint()
      ..color = Color(0xFF0f0f1e)
      ..strokeWidth = 1;

    for (double x = -cameraX % 50; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = -cameraY % 50; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw some enemy sprites
    for (var enemy in enemies) {
      _drawSprite(canvas, size, enemy);
    }

    // Draw projectiles
    final projectilePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    for (var projectile in projectiles) {
      final screenX = projectile.x - cameraX;
      final screenY = projectile.y - cameraY;
      canvas.drawCircle(Offset(screenX, screenY), 5, projectilePaint);
    }

    // Draw player
    final screenPlayerX = playerX - cameraX;
    final screenPlayerY = playerY - cameraY;

    // Player body
    final playerPaint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(screenPlayerX, screenPlayerY), 20, playerPaint);

    // Red flash when damaged
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final timeSinceDamage = now - playerLastDamageTime;
    if (timeSinceDamage < 0.15) {
      final flashAlpha = ((0.15 - timeSinceDamage) / 0.15 * 200).toInt();
      final flashPaint = Paint()..color = Color.fromARGB(flashAlpha, 255, 0, 0);
      canvas.drawCircle(Offset(screenPlayerX, screenPlayerY), 20, flashPaint);
    }

    // Player facing direction (triangle)
    final directionPaint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.fill;

    final dirLength = 25.0;
    final dirEndX = screenPlayerX + dirLength * cos(playerAngle);
    final dirEndY = screenPlayerY + dirLength * sin(playerAngle);

    canvas.drawLine(
      Offset(screenPlayerX, screenPlayerY),
      Offset(dirEndX, dirEndY),
      Paint()
        ..color = Colors.lightBlue
        ..strokeWidth = 3,
    );

    // Draw UI text
    final healthText = 'Health: ${playerHealth.toStringAsFixed(0)}/100';
    final enemiesText = 'Enemies: ${enemies.where((e) => e.isAlive()).length}';

    final textPainter = TextPainter(
      text: TextSpan(
        text:
            'WASD: Move | Mouse/Space: Attack | R: Reset | $healthText | $enemiesText',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

    // Draw health bar
    final healthBarWidth = 200.0;
    const healthBarHeight = 20.0;
    final healthPercent = max(0.0, playerHealth / 100.0);

    canvas.drawRect(
      Rect.fromLTWH(10, 40, healthBarWidth, healthBarHeight),
      Paint()..color = Colors.grey,
    );
    canvas.drawRect(
      Rect.fromLTWH(10, 40, healthBarWidth * healthPercent, healthBarHeight),
      Paint()..color = Colors.green,
    );
    canvas.drawRect(
      Rect.fromLTWH(10, 40, healthBarWidth, healthBarHeight),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawSprite(Canvas canvas, Size size, Enemy enemy) {
    final worldX = enemy.x;
    final worldY = enemy.y;
    final color = enemy.color;
    final health = enemy.health;

    final screenX = worldX - cameraX;
    final screenY = worldY - cameraY;

    if (screenX < -50 ||
        screenX > size.width + 50 ||
        screenY < -50 ||
        screenY > size.height + 50) {
      return;
    }

    // Enemy body
    final paint = Paint()..color = color;

    // Death animation
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (enemy.deathTime > 0) {
      const deathAnimationDuration = 0.3;
      final timeSinceDeath = now - enemy.deathTime;
      final deathProgress = (timeSinceDeath / deathAnimationDuration).clamp(
        0.0,
        1.0,
      );

      // Shrink and fade out
      final scale = 1.0 - deathProgress;
      final alpha = (200 * (1.0 - deathProgress)).toInt();

      paint.color = paint.color.withAlpha(alpha);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(screenX, screenY),
          width: 30 * scale,
          height: 30 * scale,
        ),
        paint,
      );

      // Explosion particle effect
      final particleCount = 8;
      final particlePaint = Paint()..color = Color.fromARGB(alpha, 255, 200, 0);
      for (int i = 0; i < particleCount; i++) {
        final angle = (i / particleCount) * 2 * pi + (deathProgress * pi);
        final distance = deathProgress * 40;
        final px = screenX + cos(angle) * distance;
        final py = screenY + sin(angle) * distance;
        canvas.drawCircle(
          Offset(px, py),
          3 * (1 - deathProgress),
          particlePaint,
        );
      }

      return;
    }

    canvas.drawRect(
      Rect.fromCenter(center: Offset(screenX, screenY), width: 30, height: 30),
      paint,
    );

    // Red flash when damaged
    final timeSinceDamage = now - enemy.lastDamageTime;
    if (timeSinceDamage < 0.15) {
      final flashAlpha = ((0.15 - timeSinceDamage) / 0.15 * 150).toInt();
      final flashPaint = Paint()..color = Color.fromARGB(flashAlpha, 255, 0, 0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(screenX, screenY),
          width: 30,
          height: 30,
        ),
        flashPaint,
      );
    }

    // Enemy eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(screenX - 7, screenY - 7), 4, eyePaint);
    canvas.drawCircle(Offset(screenX + 7, screenY - 7), 4, eyePaint);

    // Health bar above enemy
    const healthBarWidth = 30.0;
    const healthBarHeight = 4.0;
    final healthPercent = health / 30.0;

    canvas.drawRect(
      Rect.fromLTWH(
        screenX - 15,
        screenY - 25,
        healthBarWidth,
        healthBarHeight,
      ),
      Paint()..color = Colors.grey,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        screenX - 15,
        screenY - 25,
        healthBarWidth * healthPercent,
        healthBarHeight,
      ),
      Paint()..color = Colors.lime,
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
