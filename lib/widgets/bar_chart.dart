import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SimpleBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const SimpleBarChart({super.key, required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 90.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final isLast = i == data.length - 1;
          final barHeight = maxVal > 0 ? (data[i] / maxVal * 74).clamp(6.0, 74.0) : 6.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: isLast
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [context.colors.seafoam, context.colors.primary],
                            )
                          : null,
                      color: isLast ? null : context.colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(5.r),
                        bottom: Radius.circular(3.r),
                      ),
                      boxShadow: isLast
                          ? [
                              BoxShadow(
                                color: context.colors.primary.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
                      color: isLast ? context.colors.primary : context.colors.mutedLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
