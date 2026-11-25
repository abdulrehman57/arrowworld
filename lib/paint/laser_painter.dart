import 'dart:ui';

import 'package:flutter/material.dart';

class LaserPainter extends CustomPainter {
  final List<Offset> pixelPath;
  final Animation<double> animation;
  final Color laserColor;

  // Passing the animation to super(repaint:) prevents the whole screen from rebuilding
  // 60 times a second. It only repaints the laser line.
  LaserPainter({
    required this.pixelPath,
    required this.animation,
    required this.laserColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (pixelPath.length < 2 || animation.value == 0) return;

    // The Neon Outer Glow
    final glowPaint = Paint()
      ..color = laserColor.withOpacity(0.6)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..imageFilter = ImageFilter.blur(sigmaX: 8, sigmaY: 8);

    // The Bright White Core
    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(pixelPath.first.dx, pixelPath.first.dy);

    // Calculate how much of the path to draw based on the animation progress (0.0 to 1.0)
    int pointsToDraw = (pixelPath.length * animation.value).ceil();

    for (int i = 1; i < pointsToDraw && i < pixelPath.length; i++) {
      path.lineTo(pixelPath[i].dx, pixelPath[i].dy);
    }

    // Draw the glow first, then the bright core over it
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant LaserPainter oldDelegate) => true;
}
