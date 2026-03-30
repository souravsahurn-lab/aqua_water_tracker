import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../services/notification_service.dart';
import '../widgets/top_snackbar.dart';
import 'package:flutter/services.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
                                    if (userData.smartReminders) {
                                      provider.regenerateSmartReminders();
                                    }
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
                                    if (userData.smartReminders) {
                                      provider.regenerateSmartReminders();
                                    }
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                  // Regenerate button
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
                            // Manual interval selector
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
                                // Regenerate with interval
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
                          SizedBox(height: 24.h),
                          Divider(color: context.colors.softLight, height: 1),
                          SizedBox(height: 16.h),
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
                    SizedBox(height: 12.h),

                    // Add custom reminder button — ALWAYS visible
                    _buildAddReminderButton(context, provider),
                    SizedBox(height: 16.h),

                    // Sound & Effects card
                    _buildCard(context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sound & Effects',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Notification sound
                          GestureDetector(
                            onTap: () => _showSoundPicker(context, provider),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
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
                                      color: context.colors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Center(child: Text('🔔', style: TextStyle(fontSize: 18.sp))),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Sound',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                            color: context.colors.text,
                                          ),
                                        ),
                                        Text(
                                          NotificationService.availableSounds[userData.notificationSound] ?? 'Default',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, size: 20, color: context.colors.mutedLight),
                                ],
                              ),
                            ),
                          ),

                          // Sound toggle
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                                    color: context.colors.accent.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(child: Text('🎵', style: TextStyle(fontSize: 18.sp))),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Sound',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                      color: context.colors.text,
                                    ),
                                  ),
                                ),
                                _buildToggle(context, value: userData.sound, onChanged: provider.toggleSound),
                              ],
                            ),
                          ),

                          // Vibration toggle
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: context.colors.warning.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Center(child: Text('📳', style: TextStyle(fontSize: 18.sp))),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Vibration',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                      color: context.colors.text,
                                    ),
                                  ),
                                ),
                                _buildToggle(context, value: userData.vibration, onChanged: provider.toggleVibration),
                              ],
                            ),
                          ),
                        ],
                      ),
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
          boxShadow: value
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.w,
            height: 20.h,
            margin: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildAddReminderButton(BuildContext context, HydrationProvider provider) {
    return Material(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            provider.addCustomReminder(picked);
            if (context.mounted) {
              TopSnackBar.show(context, message: 'Reminder added at ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} 🔔', type: TopSnackBarType.success);
            }
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 18.sp, color: context.colors.primary),
              SizedBox(width: 8.w),
              Text(
                'Add Custom Reminder',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ALL reminders are editable and deletable, regardless of smart/manual mode
  List<Widget> _buildRemindersList(BuildContext context, HydrationProvider provider) {
    final now = TimeOfDay.now();
    final reminders = provider.generatedReminders;

    if (reminders.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: Text(
              'No reminders set. Tap "Add Custom Reminder" below!',
              style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    return reminders.asMap().entries.map((entry) {
      final idx = entry.key;
      final t = entry.value;
      final isPast = t.hour < now.hour || (t.hour == now.hour && t.minute <= now.minute);
      final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      
      // Get the preview message for this time
      final previewMsg = NotificationService.getMessageForTime(t.hour);

      return Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.softLight, width: 1.w),
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: isPast
                    ? context.colors.primary.withValues(alpha: 0.09)
                    : context.colors.softLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: isPast
                    ? Icon(Icons.check_rounded, size: 16.sp, color: context.colors.primary)
                    : Text('💧', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewMsg,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: isPast ? context.colors.mutedLight : context.colors.text,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isPast ? context.colors.mutedLight : context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: t,
                  );
                  if (picked != null) {
                    provider.updateCustomReminder(idx, picked);
                    if (context.mounted) {
                      TopSnackBar.show(context, message: 'Reminder updated ✏️', type: TopSnackBarType.info);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16.sp,
                    color: context.colors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            // Delete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  provider.removeCustomReminder(idx);
                  TopSnackBar.show(context, message: 'Reminder removed', type: TopSnackBarType.error);
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16.sp,
                    color: context.colors.danger.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showSoundPicker(BuildContext context, HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SoundPickerSheet(provider: provider),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Sound Picker Bottom Sheet
// ═════════════════════════════════════════════════════════════════════
class _SoundPickerSheet extends StatefulWidget {
  final HydrationProvider provider;
  const _SoundPickerSheet({required this.provider});

  @override
  State<_SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<_SoundPickerSheet> {
  String? _playingSound;

  @override
  Widget build(BuildContext context) {
    final currentSound = widget.provider.userData.notificationSound;
    final sounds = NotificationService.availableSounds;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.colors.softLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Notification Sound',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap ▶ to preview, tap the row to select',
            style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight),
          ),
          SizedBox(height: 20.h),

          ...sounds.entries.map((entry) {
            final soundKey = entry.key;
            final displayName = entry.value;
            final isSelected = currentSound == soundKey;
            final isPlaying = _playingSound == soundKey;

            String icon;
            if (displayName.contains('Splash')) {
              icon = '🌊';
            } else if (displayName.contains('Classic')) {
              icon = '💎';
            } else if (displayName.contains('Droplet')) {
              icon = '💧';
            } else if (displayName.contains('Drop 2')) {
              icon = '🫧';
            } else {
              icon = '💦';
            }

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.provider.updateNotificationSound(soundKey);
                Navigator.pop(context);
                TopSnackBar.show(context, message: '$displayName selected 🔔', type: TopSnackBarType.success);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.08)
                      : context.colors.bg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.softLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primary.withValues(alpha: 0.12)
                            : context.colors.softLight,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(icon, style: TextStyle(fontSize: 20.sp)),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: isSelected
                                  ? context.colors.primary
                                  : context.colors.text,
                            ),
                          ),
                          if (isSelected)
                            Text(
                              'Currently selected',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: context.colors.primary,
                              ),
                            ),
                          if (isPlaying)
                            Text(
                              'Playing preview...',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: context.colors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Preview / Play button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          setState(() { _playingSound = soundKey; });
                          
                          await NotificationService().playTestNotification(
                            soundName: soundKey,
                            vibrationEnabled: widget.provider.userData.vibration,
                          );
                          
                          // Reset playing state after a delay
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() { _playingSound = null; });
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? context.colors.success.withValues(alpha: 0.12)
                                : context.colors.softLight,
                            borderRadius: BorderRadius.circular(10.r),
                            border: isPlaying
                                ? Border.all(color: context.colors.success.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Icon(
                            isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                            size: 20.sp,
                            color: isPlaying ? context.colors.success : context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Selection indicator
                    Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        gradient: isSelected ? context.colors.primaryGradient : null,
                        color: isSelected ? null : context.colors.softLight,
                        shape: BoxShape.circle,
                        border: !isSelected
                            ? Border.all(color: context.colors.muted.withValues(alpha: 0.3))
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
