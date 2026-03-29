import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveClipper extends CustomClipper<Path> {
  final double animValue;

  WaveClipper({this.animValue = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);

    final phase = animValue * 2 * math.pi;
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.5 +
          math.sin((x / size.width * 2 * math.pi) + phase) * size.height * 0.15 +
          math.sin((x / size.width * 4 * math.pi) + phase * 1.5) * size.height * 0.08;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => oldClipper.animValue != animValue;
}

class WaveDecoration extends StatelessWidget {
  final Color color;
  final double opacity;
  final double height;

  const WaveDecoration({
    super.key,
    required this.color,
    this.opacity = 0.08,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _WavePainter(color: color, opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double opacity;

  _WavePainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    // First wave
    final paint1 = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.cubicTo(
      size.width * 0.2, size.height * 0.125,
      size.width * 0.4, size.height * 0.875,
      size.width * 0.6, size.height * 0.5,
    );
    path1.cubicTo(
      size.width * 0.8, size.height * 0.125,
      size.width * 0.9, size.height * 0.75,
      size.width, size.height * 0.4375,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave
    final paint2 = Paint()
      ..color = color.withValues(alpha: opacity + 0.06)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6875);
    path2.cubicTo(
      size.width * 0.175, size.height * 0.375,
      size.width * 0.375, size.height * 0.9375,
      size.width * 0.575, size.height * 0.625,
    );
    path2.cubicTo(
      size.width * 0.775, size.height * 0.3125,
      size.width * 0.9, size.height * 0.8125,
      size.width, size.height * 0.5625,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
