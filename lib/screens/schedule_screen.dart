import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/app_button.dart';
import 'package:flutter/services.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final userData = provider.userData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16.h + MediaQuery.of(context).padding.top, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your daily reminders',
                    style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 110.h + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    // Sleep Schedule card
                    _buildCard(context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sleep Schedule',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeCard(
                                  context,
                                  icon: '🌅',
                                  label: 'Wake Up',
                                  time: userData.wakeTime,
                                  onTap: () =>
                                      _pickTime(context, userData.wakeTime, (t) {
                                    provider.updateWakeTime(t);
                                  }),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _buildTimeCard(
                                  context,
                                  icon: '🌙',
                                  label: 'Bedtime',
                                  time: userData.sleepTime,
                                  onTap: () =>
                                      _pickTime(context, userData.sleepTime, (t) {
                                    provider.updateSleepTime(t);
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Today's Reminders card
                    _buildCard(context,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today's Reminders",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: context.colors.primaryDark,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${provider.generatedReminders.length} set',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          ..._buildRemindersList(context, provider),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    AppButton(
                      text: '+ Add Custom Reminder',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.softLight),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.softLight,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 22.sp)),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: context.colors.mutedLight),
            ),
            SizedBox(height: 6.h),
            Text(
              time,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    String current,
    ValueChanged<String> onPicked,
  ) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      onPicked(
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  List<Widget> _buildRemindersList(BuildContext context, HydrationProvider provider) {
    final now = TimeOfDay.now();
    final reminders = provider.generatedReminders.map((t) {
      final isPast = t.hour < now.hour || (t.hour == now.hour && t.minute <= now.minute);
      return {
        'time': '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        'label': 'Hydration Reminder',
        'icon': '💧',
        'done': isPast,
      };
    }).toList();

    return reminders.map((r) {
      final done = r['done'] as bool;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.softLight, width: 1.w),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: done
                    ? context.colors.primary.withValues(alpha: 0.09)
                    : context.colors.softLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(r['icon'] as String,
                    style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: done ? context.colors.mutedLight : context.colors.text,
                      decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  Text(
                    r['time'] as String,
                    style: TextStyle(
                        fontSize: 11.sp, color: context.colors.mutedLight),
                  ),
                ],
              ),
            ),
            Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                gradient: done ? context.colors.primaryGradient : null,
                color: done ? null : context.colors.softLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: done
                  ? Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      );
    }).toList();
  }
}
