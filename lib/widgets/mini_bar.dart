import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MiniBar extends StatelessWidget {
  final double val;
  final double max;
  final Color color;
  final String label;
  final String sub;

  const MiniBar({
    super.key,
    required this.val,
    required this.max,
    required this.color,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (val / max * 100).clamp(0, 100).toDouble() : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colors.mutedLight,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            height: 7.h,
            decoration: BoxDecoration(
              color: context.colors.softLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                widthFactor: pct / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
