import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class SparkLine extends StatelessWidget {
  final List<double> data;
  final Color color;

  const SparkLine({super.key, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkLinePainter(data: data, color: color),
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparkLinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = data.length > 1 ? (i / (data.length - 1)) * size.width : size.width / 2;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 18) - 6;
      points.add(Offset(x, y));
    }

    // Area fill gradient
    final areaPath = Path();
    areaPath.moveTo(0, size.height);
    for (final pt in points) {
      areaPath.lineTo(pt.dx, pt.dy);
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.25),
        color.withValues(alpha: 0),
      ],
    );
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line
    if (points.length > 1) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // End dot
    if (points.isNotEmpty) {
      final last = points.last;
      canvas.drawCircle(
        last,
        4,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        last,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_SparkLinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}
