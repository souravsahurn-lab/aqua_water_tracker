import 'package:flutter/material.dart';

class AppTheme {
  // ─── Water / Ocean Theme Colors ─────────────────────────────────────
  static Color bg = Color(0xFFEAF6FF);
  static Color bgDeep = Color(0xFFD4EFFF);
  static Color card = Color(0xFFFFFFFF);
  static Color primary = Color(0xFF0077B6);
  static Color primaryLight = Color(0xFF48CAE4);
  static Color primaryDark = Color(0xFF023E8A);
  static Color accent = Color(0xFF00B4D8);
  static Color teal = Color(0xFF0096C7);
  static Color seafoam = Color(0xFF90E0EF);
  static Color seafoamLight = Color(0xFFCAF0F8);
  static Color warning = Color(0xFFF7B731);
  static Color danger = Color(0xFFEF476F);
  static Color success = Color(0xFF06D6A0);
  static Color text = Color(0xFF03045E);
  static Color muted = Color(0xFF4895EF);
  static Color mutedLight = Color(0xFF7BBFEA);
  static Color soft = Color(0xFFADE8F4);
  static Color softLight = Color(0xFFE0F7FF);

  // ─── Gradients ──────────────────────────────────────────────────────
  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static LinearGradient headerGradient = LinearGradient(
    begin: Alignment(-0.3, -1),
    end: Alignment(0.3, 1),
    colors: [primaryDark, primary, accent],
    stops: [0.0, 0.6, 1.0],
  );

  static LinearGradient splashGradient = LinearGradient(
    begin: Alignment(-0.2, -1),
    end: Alignment(0.2, 1),
    colors: [primaryDark, primary, accent],
    stops: [0.0, 0.55, 1.0],
  );
}
