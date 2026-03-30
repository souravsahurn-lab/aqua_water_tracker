import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';

class DailyLogSheet extends StatelessWidget {
  final DateTime date;

  const DailyLogSheet({super.key, required this.date});

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
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 40.h),
      decoration: BoxDecoration(
        color: context.colors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: context.colors.softLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: context.colors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Hydration History',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Total overview card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isGoalMet ? context.colors.success : context.colors.card,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isGoalMet
                  ? [
                      BoxShadow(
                        color: context.colors.success.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      )
                    ],
              border: !isGoalMet ? Border.all(color: context.colors.softLight) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Intake',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isGoalMet ? Colors.white.withValues(alpha: 0.8) : context.colors.mutedLight,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalMl',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: isGoalMet ? Colors.white : context.colors.primaryDark,
                            height: 1,
                            letterSpacing: -1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h, left: 4.w),
                          child: Text(
                            '/ ${goal}ml',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isGoalMet ? Colors.white.withValues(alpha: 0.8) : context.colors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isGoalMet ? Colors.white.withValues(alpha: 0.2) : context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isGoalMet ? Icons.celebration_rounded : Icons.water_drop_rounded,
                    color: isGoalMet ? Colors.white : context.colors.primary,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          Text(
            'Logs',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 12.h),

          // Lists
          Expanded(
            child: dayLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 48.sp, color: context.colors.soft),
                        SizedBox(height: 16.h),
                        Text(
                          'No records found for this day.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.colors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: dayLogs.length,
                    itemBuilder: (context, i) {
                      final item = dayLogs[i];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: context.colors.softLight, width: 1.w),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                item.icon,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: context.colors.primaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: context.colors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${item.ml} ml',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
