import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color bgDeep;
  final Color card;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color teal;
  final Color seafoam;
  final Color seafoamLight;
  final Color warning;
  final Color danger;
  final Color success;
  final Color text;
  final Color muted;
  final Color mutedLight;
  final Color soft;
  final Color softLight;

  final LinearGradient primaryGradient;
  final LinearGradient headerGradient;
  final LinearGradient splashGradient;

  const AppColors({
    required this.bg,
    required this.bgDeep,
    required this.card,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.teal,
    required this.seafoam,
    required this.seafoamLight,
    required this.warning,
    required this.danger,
    required this.success,
    required this.text,
    required this.muted,
    required this.mutedLight,
    required this.soft,
    required this.softLight,
    required this.primaryGradient,
    required this.headerGradient,
    required this.splashGradient,
  });

  @override
  AppColors copyWith({
    Color? bg,
    Color? bgDeep,
    Color? card,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? accent,
    Color? teal,
    Color? seafoam,
    Color? seafoamLight,
    Color? warning,
    Color? danger,
    Color? success,
    Color? text,
    Color? muted,
    Color? mutedLight,
    Color? soft,
    Color? softLight,
    LinearGradient? primaryGradient,
    LinearGradient? headerGradient,
    LinearGradient? splashGradient,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      bgDeep: bgDeep ?? this.bgDeep,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      accent: accent ?? this.accent,
      teal: teal ?? this.teal,
      seafoam: seafoam ?? this.seafoam,
      seafoamLight: seafoamLight ?? this.seafoamLight,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      mutedLight: mutedLight ?? this.mutedLight,
      soft: soft ?? this.soft,
      softLight: softLight ?? this.softLight,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      headerGradient: headerGradient ?? this.headerGradient,
      splashGradient: splashGradient ?? this.splashGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      seafoam: Color.lerp(seafoam, other.seafoam, t)!,
      seafoamLight: Color.lerp(seafoamLight, other.seafoamLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedLight: Color.lerp(mutedLight, other.mutedLight, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
      softLight: Color.lerp(softLight, other.softLight, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      headerGradient: LinearGradient.lerp(headerGradient, other.headerGradient, t)!,
      splashGradient: LinearGradient.lerp(splashGradient, other.splashGradient, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  static final AppColors light = AppColors(
    bg: Color(0xFFEAF6FF),
    bgDeep: Color(0xFFD4EFFF),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF0077B6),
    primaryLight: Color(0xFF48CAE4),
    primaryDark: Color(0xFF023E8A),
    accent: Color(0xFF00B4D8),
    teal: Color(0xFF0096C7),
    seafoam: Color(0xFF90E0EF),
    seafoamLight: Color(0xFFCAF0F8),
    warning: Color(0xFFF7B731),
    danger: Color(0xFFEF476F),
    success: Color(0xFF06D6A0),
    text: Color(0xFF03045E),
    muted: Color(0xFF4895EF),
    mutedLight: Color(0xFF7BBFEA),
    soft: Color(0xFFADE8F4),
    softLight: Color(0xFFE0F7FF),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    ),
    headerGradient: LinearGradient(
      begin: Alignment(-0.3, -1),
      end: Alignment(0.3, 1),
      colors: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF00B4D8)],
      stops: [0.0, 0.6, 1.0],
    ),
    splashGradient: LinearGradient(
      begin: Alignment(-0.2, -1),
      end: Alignment(0.2, 1),
      colors: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF00B4D8)],
      stops: [0.0, 0.55, 1.0],
    ),
  );

  static final AppColors dark = AppColors(
    bg: Color(0xFF0A0F14),        
    bgDeep: Color(0xFF05080A),
    card: Color(0xFF141E26),      
    primary: Color(0xFF00B4D8),   
    primaryLight: Color(0xFF90E0EF),
    primaryDark: Color(0xFF0077B6),
    accent: Color(0xFF48CAE4),
    teal: Color(0xFF0096C7),
    seafoam: Color(0xFF82C8D6),
    seafoamLight: Color(0xFF2B414F),
    warning: Color(0xFFEAB143),
    danger: Color(0xFFEB5E7F),
    success: Color(0xFF14C89A),
    text: Color(0xFFEAF6FF),      
    muted: Color(0xFF7CA6CD),
    mutedLight: Color(0xFF5A7F9D),
    soft: Color(0xFF1E2D3A),
    softLight: Color(0xFF14202A),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
    ),
    headerGradient: LinearGradient(
      begin: Alignment(-0.3, -1),
      end: Alignment(0.3, 1),
      colors: [Color(0xFF05080A), Color(0xFF141E26), Color(0xFF1E2D3A)],
      stops: [0.0, 0.6, 1.0],
    ),
    splashGradient: LinearGradient(
      begin: Alignment(-0.2, -1),
      end: Alignment(0.2, 1),
      colors: [Color(0xFF0A0F14), Color(0xFF0077B6), Color(0xFF00B4D8)],
      stops: [0.0, 0.55, 1.0],
    ),
  );
}
