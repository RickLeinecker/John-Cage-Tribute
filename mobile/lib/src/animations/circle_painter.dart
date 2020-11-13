import 'dart:math' as math show sqrt;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color color;
  final Animation<double> _animation;

  CirclePainter(
    this._animation, {
    @required this.color,
  }) : super(repaint: _animation);

  void circle(Canvas canvas, Rect rect, double value) {
    final double opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0);
    final Color _color = color.withOpacity(opacity);
    final double size = rect.width;
    final double area = size * size;
    final double radius = math.sqrt(area * value / 4);
    final Paint paint = Paint()..color = _color;

    canvas.drawCircle(rect.center, radius * 3 / 4, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation.value);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}
