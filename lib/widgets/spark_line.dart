import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class SparkLine extends StatelessWidget {
  final List<double> data;
  final Color color;
  final List<String>? labels;

  const SparkLine({
    super.key, 
    required this.data, 
    required this.color,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: labels != null ? 80.h : 60.h,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkLinePainter(data: data, color: color, labels: labels),
      ),
    );
  }
}

class _SparkLinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final List<String>? labels;

  _SparkLinePainter({
    required this.data, 
    required this.color, 
    this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final bottomPadding = labels != null ? 24.0 : 6.0;
    final graphHeight = size.height - bottomPadding - 18.0;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = data.length > 1 ? (i / (data.length - 1)) * size.width : size.width / 2;
      final y = size.height - bottomPadding - ((data[i] - minVal) / range) * graphHeight;
      points.add(Offset(x, y));
    }

    // Area fill gradient
    final areaPath = Path();
    areaPath.moveTo(0, size.height - bottomPadding);
    for (final pt in points) {
      areaPath.lineTo(pt.dx, pt.dy);
    }
    areaPath.lineTo(size.width, size.height - bottomPadding);
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
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height - bottomPadding))
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

    // Labels
    if (labels != null && labels!.isNotEmpty) {
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      for (int i = 0; i < points.length; i++) {
        if (i < labels!.length) {
          textPainter.text = TextSpan(
            text: labels![i],
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          );
          textPainter.layout();
          final x = points[i].dx - (textPainter.width / 2);
          textPainter.paint(canvas, Offset(x, size.height - bottomPadding + 8));
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SparkLinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color || oldDelegate.labels != labels;
}
