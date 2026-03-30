import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MonthCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final goal = provider.userData.goal;
    
    // Calculate month metrics
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // 1(Mon) to 7(Sun)
    int firstWeekday = firstDayOfMonth.weekday;
    // Map: Mon=0, Tue=1... Sun=6
    int leadingEmptyDays = firstWeekday - 1;

    final today = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
            return SizedBox(
              width: 32.w,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.mutedLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 12.h),

        // Grid of dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingEmptyDays + daysInMonth,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 4.w,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index < leadingEmptyDays) {
              return const SizedBox.shrink(); // Empty grid cell
            }
            
            final day = index - leadingEmptyDays + 1;
            final date = DateTime(selectedDate.year, selectedDate.month, day);
            final dateStr = date.toIso8601String().split('T')[0];
            final todayStr = today.toIso8601String().split('T')[0];
            final selectedStr = selectedDate.toIso8601String().split('T')[0];
            
            // Calculate intake
            final dayLogs = provider.logs.where((l) => l.date == dateStr);
            final totalMl = dayLogs.fold<int>(0, (sum, l) => sum + l.ml);
            final pct = goal > 0 ? (totalMl / goal).clamp(0.0, 1.0) : 0.0;
            
            final isSelected = dateStr == selectedStr;
            final isToday = dateStr == todayStr;
            
            return GestureDetector(
              onTap: () {
                onDateSelected(date);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: context.colors.primary.withValues(alpha: 0.5), width: 1.5)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The background progress ring if there's data
                    if (!isSelected && pct > 0)
                      SizedBox(
                        width: 34.w,
                        height: 34.w,
                        child: CircularProgressIndicator(
                          value: pct,
                          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                          color: pct >= 1.0 ? context.colors.success : context.colors.primary,
                          strokeWidth: 2.5.w,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    
                    // The text inside
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected 
                            ? Colors.white 
                            : (pct >= 1.0 ? context.colors.success : context.colors.text),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
