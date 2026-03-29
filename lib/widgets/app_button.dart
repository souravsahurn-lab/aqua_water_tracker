import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, ghost, secondary }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final EdgeInsets? padding;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.padding,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _scale = 0.97),
      onTapUp: widget.onPressed == null ? null : (_) => setState(() => _scale = 1.0),
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          padding: widget.padding ?? EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            gradient: widget.variant == AppButtonVariant.primary
                ? AppTheme.primaryGradient
                : null,
            color: widget.variant == AppButtonVariant.ghost
                ? Colors.transparent
                : widget.variant == AppButtonVariant.secondary
                    ? widget.backgroundColor ?? AppTheme.softLight
                    : null,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: widget.variant == AppButtonVariant.primary
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.27),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: widget.fontSize ?? 15,
              letterSpacing: 0.3,
              color: widget.textColor ??
                  (widget.variant == AppButtonVariant.primary
                      ? Colors.white
                      : widget.variant == AppButtonVariant.ghost
                          ? AppTheme.primary
                          : AppTheme.text),
            ),
          ),
        ),
      ),
    );
  }
}
