import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../services/notification_service.dart';
import '../widgets/top_snackbar.dart';
import '../widgets/live_permission_warning.dart';
import '../utils/time_utils.dart';

class AquaReminderScreen extends StatefulWidget {
  const AquaReminderScreen({super.key});

  @override
  State<AquaReminderScreen> createState() => _AquaReminderScreenState();
}

class _AquaReminderScreenState extends State<AquaReminderScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final userData = provider.userData;
        final now = TimeOfDay.now();
        final reminders = provider.generatedReminders;

        return Scaffold(
          backgroundColor: context.colors.bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.primaryDark, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Aqua Reminders',
              style: TextStyle(
                color: context.colors.primaryDark,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LivePermissionWarning(),
                SizedBox(height: 16.h),
                // Smart Toggle Card
                _buildCard(context,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 20.sp,
                              color: context.colors.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Reminders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                    color: context.colors.primaryDark,
                                  ),
                                ),
                                Text(
                                  userData.smartReminders
                                      ? 'Auto-adjusts based on your goal'
                                      : 'Set your own interval',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: context.colors.mutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildToggle(
                            context,
                            value: userData.smartReminders,
                            onChanged: (val) {
                              provider.toggleSmartReminders(val);
                            },
                          ),
                        ],
                      ),
                      if (userData.smartReminders) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 16.sp, color: context.colors.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Auto-set to every ${provider.effectiveInterval} min based on your ${userData.goal}ml goal',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  provider.regenerateSmartReminders();
                                  TopSnackBar.show(context, message: 'Reminders recalculated ✨', type: TopSnackBarType.success);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.refresh_rounded, size: 12.sp, color: context.colors.primary),
                                      SizedBox(width: 4.w),
                                      Text('Reset', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: context.colors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REMINDER INTERVAL',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: context.colors.mutedLight,
                                letterSpacing: 1.2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                provider.regenerateSmartReminders();
                                TopSnackBar.show(context, message: 'Reminders regenerated with ${userData.reminderIntervalMin}min interval', type: TopSnackBarType.success);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.autorenew_rounded, size: 11.sp, color: context.colors.primary),
                                    SizedBox(width: 3.w),
                                    Text('Regenerate', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: context.colors.primary)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [30, 45, 60, 90, 120, 180].map((mins) {
                            final isSelected = userData.reminderIntervalMin == mins;
                            final label = mins >= 60 
                                ? '${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}'
                                : '${mins}m';
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                provider.updateReminderInterval(mins);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.colors.primary.withValues(alpha: 0.12)
                                      : context.colors.softLight,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? context.colors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? context.colors.primary
                                        : context.colors.text,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Reminders List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Sequence",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${reminders.length} scheduled',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Reminders List
                if (reminders.isEmpty)
                  _buildEmptyState(context)
                else
                  ...reminders.asMap().entries.map((entry) => _buildReminderItem(context, provider, entry.key, entry.value, now)),

                SizedBox(height: 100.h), // Space for FAB
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context, provider),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context, HydrationProvider provider) {
    return Container(
      height: 56.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        gradient: context.colors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            final picked = await showTimePicker(
              context: context, 
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: provider.userData.is24HourFormat ?? false),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              provider.addCustomReminder(picked);
              if (mounted) TopSnackBar.show(context, message: 'Reminder added! 🔔', type: TopSnackBarType.success);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add Custom Reminder',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildReminderItem(BuildContext context, HydrationProvider provider, int idx, TimeOfDay t, TimeOfDay now) {
    final isPast = t.hour < now.hour || (t.hour == now.hour && t.minute <= now.minute);
    final is24h = provider.userData.is24HourFormat ?? false;
    final timeStr = TimeUtils.formatTimeOfDay(t, is24h);
    final previewMsg = NotificationService.getMessageForTime(t.hour);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isPast ? context.colors.softLight : context.colors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: isPast
                  ? context.colors.primary.withValues(alpha: 0.09)
                  : context.colors.softLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: isPast
                  ? Icon(Icons.check_rounded, size: 18.sp, color: context.colors.primary)
                  : Text('💧', style: TextStyle(fontSize: 18.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isPast ? context.colors.mutedLight : context.colors.primary,
                  ),
                ),
                Text(
                  previewMsg,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    color: isPast ? context.colors.mutedLight : context.colors.text.withValues(alpha: 0.7),
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 18.sp, color: context.colors.mutedLight),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final picked = await showTimePicker(
                context: context, 
                initialTime: t,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: is24h),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                provider.updateCustomReminder(idx, picked);
                if (mounted) TopSnackBar.show(context, message: 'Updated ✏️', type: TopSnackBarType.info);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: context.colors.danger.withValues(alpha: 0.6)),
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.removeCustomReminder(idx);
              TopSnackBar.show(context, message: 'Removed', type: TopSnackBarType.error);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Text('🔔', style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: 12.h),
            Text(
              'No reminders set.',
              style: TextStyle(fontSize: 14.sp, color: context.colors.mutedLight, fontWeight: FontWeight.w600),
            ),
            Text(
              'Tap below to add your first reminder!',
              style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildToggle(BuildContext context, {required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46.w,
        height: 26.h,
        decoration: BoxDecoration(
          gradient: value ? context.colors.primaryGradient : null,
          color: value ? null : context.colors.softLight,
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.w,
            height: 20.h,
            margin: EdgeInsets.all(3.w),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
