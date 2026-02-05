import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arpg/config/constants.dart';

class SmearComponent extends PositionComponent {
  final double direction;
  final double radius;
  final double life = SmearConstants.life; // 2 frames at 60fps
  double elapsed = 0.0;

  SmearComponent(Vector2 pos, this.direction, this.radius)
    : super(position: pos, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;
    if (elapsed >= life) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tip = Offset(cos(direction) * radius, sin(direction) * radius);
    final perp = Offset(
      -sin(direction) * (radius * SmearConstants.perpMul),
      cos(direction) * (radius * SmearConstants.perpMul),
    );
    final p1 = Offset.zero;
    final p2 = tip + perp;
    final p3 = tip - perp;
    final alpha = (1 - (elapsed / life)).clamp(0.0, 1.0);
    final p = Paint()
      ..color = Color.fromRGBO(255, 255, 255, alpha)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = SmearConstants.strokeWidth,
    );
  }
}
