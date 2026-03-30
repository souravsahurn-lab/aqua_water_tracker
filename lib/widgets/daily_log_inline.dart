import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';

class DailyLogInline extends StatelessWidget {
  final DateTime date;

  const DailyLogInline({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final dateStr = date.toIso8601String().split('T')[0];
    final dayLogs = provider.logs.where((l) => l.date == dateStr).toList();
    final totalMl = dayLogs.fold<int>(0, (sum, l) => sum + l.ml);
    final goal = provider.userData.goal;
    
    // Sort logs by time
    dayLogs.sort((a, b) => b.time.compareTo(a.time));

    final isGoalMet = totalMl >= goal;
    final displayDate = DateFormat('MMMM d, yyyy').format(date);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isGoalMet ? context.colors.success.withValues(alpha: 0.3) : context.colors.softLight, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: isGoalMet 
                ? context.colors.success.withValues(alpha: 0.05) 
                : context.colors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isGoalMet ? 'Goal Reached! 🎉' : 'Daily Record',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isGoalMet ? context.colors.success : context.colors.mutedLight,
                        fontWeight: isGoalMet ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalMl ml',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: isGoalMet ? context.colors.success : context.colors.primary,
                      height: 1,
                    ),
                  ),
                  Text(
                    'of ${goal}ml goal',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.mutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (dayLogs.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(color: context.colors.softLight),
            ),
            // Professional, compact vertical log list
            Column(
              children: dayLogs.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    children: [
                      // Time
                      SizedBox(
                        width: 45.w,
                        child: Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: context.colors.muted,
                          ),
                        ),
                      ),
                      // Icon + Amount
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: context.colors.softLight,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.icon, style: TextStyle(fontSize: 12.sp)),
                            SizedBox(width: 6.w),
                            Text(
                              '${item.ml} ml',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // Label
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colors.mutedLight,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'No logs for this day.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colors.mutedLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
