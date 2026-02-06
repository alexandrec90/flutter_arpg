import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'dart:math';
import 'package:flutter_arpg/arpg_game.dart';
import 'package:flame/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ARPGGame _game;

  @override
  void initState() {
    super.initState();
    _game = ARPGGame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isometric ARPG — Elastic Combat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            // Convert tap (screen coordinates) to a direction relative to player
            final tap = details.localPosition;
            final playerPos = _game.player.position;
            final dx = tap.dx - playerPos.x;
            final dy = tap.dy - playerPos.y;
            final angle = atan2(dy, dx);
            _game.spawnProjectile(playerPos.clone(), angle);
          },
          child: GameWidget(game: _game),
        ),
      ),
    );
  }
}

// Legacy Flutter + CustomPainter game removed — use `ARPGGame` in `lib/arpg_game.dart`.
