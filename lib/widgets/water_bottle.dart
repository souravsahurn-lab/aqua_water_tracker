import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class WaterBottle extends StatefulWidget {
  final double pct;
  final double size;

  const WaterBottle({super.key, this.pct = 0, this.size = 160});

  @override
  State<WaterBottle> createState() => _WaterBottleState();
}

class _WaterBottleState extends State<WaterBottle>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = widget.size * 0.55;
    final h = widget.size;
    final fillPct = widget.pct.clamp(0, 100).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaterBottlePainter(
              fillPct: fillPct,
              wavePhase: _waveController.value,
              accentColor: c.accent,
              primaryColor: c.primary,
              tealColor: c.teal,
              seafoamColor: c.seafoam,
              mutedLightColor: c.mutedLight,
              isDark: isDark,
            ),
            size: Size(w, h),
          );
        },
      ),
    );
  }
}

class _WaterBottlePainter extends CustomPainter {
  final double fillPct;
  final double wavePhase;
  final Color accentColor;
  final Color primaryColor;
  final Color tealColor;
  final Color seafoamColor;
  final Color mutedLightColor;
  final bool isDark;

  _WaterBottlePainter({
    required this.fillPct,
    required this.wavePhase,
    required this.accentColor,
    required this.primaryColor,
    required this.tealColor,
    required this.seafoamColor,
    required this.mutedLightColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale factors based on the SVG viewBox (88x160)
    final sx = w / 88;
    final sy = h / 160;

    // ─── Cap ──────────────────────────────────────────────────────────
    // Cap gradient
    final capGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accentColor, primaryColor],
    );
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(31 * sx, 9 * sy, 26 * sx, 13 * sy),
      Radius.circular(4 * sx),
    );
    canvas.drawRRect(
      capRect,
      Paint()
        ..shader = capGradient.createShader(capRect.outerRect)
        ..style = PaintingStyle.fill,
    );

    // Top ring
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(34 * sx, 4 * sy, 20 * sx, 7 * sy),
        Radius.circular(3 * sx),
      ),
      Paint()
        ..color = tealColor
        ..style = PaintingStyle.fill,
    );

    // Cap highlight
    canvas.drawLine(
      Offset(34 * sx, 12 * sy),
      Offset(54 * sx, 12 * sy),
      Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5 * sx,
    );

    // ─── Bottle body ──────────────────────────────────────────────────
    final bodyPath = _bottlePath(sx, sy);

    // White/Glass fill
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white
        ..style = PaintingStyle.fill,
    );

    // Seafoam stroke
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = seafoamColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ─── Water fill ───────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(bodyPath);

    final fillY = (100 - fillPct) / 100 * h;
    // Subtle bob animation
    final bob = math.sin(wavePhase * 2 * math.pi) * 2 * sy;

    // Water gradient
    final waterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [seafoamColor.withValues(alpha: 0.95), primaryColor],
    );
    final waterRect = Rect.fromLTWH(9 * sx, fillY + bob, 70 * sx, h);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = waterGradient.createShader(waterRect)
        ..style = PaintingStyle.fill,
    );

    // Wave surface
    final wavePath = Path();
    final waveY = fillY + bob;
    wavePath.moveTo(9 * sx, waveY);
    for (double x = 9 * sx; x <= 79 * sx; x += 1) {
      final normalizedX = (x - 9 * sx) / (70 * sx);
      final y = waveY +
          math.sin(normalizedX * 2 * math.pi + wavePhase * 2 * math.pi) *
              3 *
              sy +
          math.sin(
                  normalizedX * 4 * math.pi + wavePhase * 2 * math.pi * 1.3) *
              1.5 *
              sy;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(79 * sx, h);
    wavePath.lineTo(9 * sx, h);
    wavePath.close();
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Shine overlay
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0),
        ],
        stops: [0, 0.4, 1],
      ).createShader(Rect.fromLTWH(9 * sx, 0, 70 * sx, h));
    canvas.drawRect(Rect.fromLTWH(9 * sx, 0, 70 * sx, h), shinePaint);

    canvas.restore();

    // ─── Bottle outline ───────────────────────────────────────────────
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Left shine
    final shinePath = Path();
    shinePath.moveTo(22 * sx, 44 * sy);
    shinePath.cubicTo(
      20 * sx, 60 * sy,
      20 * sx, 100 * sy,
      22 * sx, 128 * sy,
    );
    canvas.drawPath(
      shinePath,
      Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // ─── Measurement marks ────────────────────────────────────────────
    for (final m in [25, 50, 75]) {
      final markY = (100 - m + 4) / 100 * h;
      canvas.drawLine(
        Offset(74 * sx, markY),
        Offset(80 * sx, markY),
        Paint()
          ..color = seafoamColor.withValues(alpha: 0.9)
          ..strokeWidth = 1.2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$m%',
          style: TextStyle(
            fontSize: 6 * sx,
            color: mutedLightColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(82 * sx, markY - 3 * sy));
    }
  }

  Path _bottlePath(double sx, double sy) {
    final path = Path();
    path.moveTo(28 * sx, 20 * sy);
    path.cubicTo(20 * sx, 20 * sy, 14 * sx, 26 * sy, 14 * sx, 34 * sy);
    path.lineTo(10 * sx, 142 * sy);
    path.cubicTo(10 * sx, 152 * sy, 18 * sx, 158 * sy, 28 * sx, 158 * sy);
    path.lineTo(60 * sx, 158 * sy);
    path.cubicTo(70 * sx, 158 * sy, 78 * sx, 152 * sy, 78 * sx, 142 * sy);
    path.lineTo(74 * sx, 34 * sy);
    path.cubicTo(74 * sx, 26 * sy, 68 * sx, 20 * sy, 60 * sx, 20 * sy);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_WaterBottlePainter oldDelegate) =>
      oldDelegate.fillPct != fillPct || oldDelegate.wavePhase != wavePhase;
}
