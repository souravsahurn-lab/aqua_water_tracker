import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../services/notification_service.dart';
import '../widgets/top_snackbar.dart';
import 'package:flutter/services.dart';
import 'aqua_reminder_screen.dart';
import '../widgets/live_permission_warning.dart';
import '../utils/time_utils.dart';

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
                                  time: TimeUtils.formatString(userData.wakeTime, userData.is24HourFormat),
                                  onTap: () =>
                                      _pickTime(context, userData.wakeTime, userData.is24HourFormat ?? false, (t) {
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
                                  time: TimeUtils.formatString(userData.sleepTime, userData.is24HourFormat),
                                  onTap: () =>
                                      _pickTime(context, userData.sleepTime, userData.is24HourFormat ?? false, (t) {
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

                    // Aqua Reminder Navigation Card
                    _buildNavCard(
                      context,
                      title: 'Aqua Reminders',
                      subtitle: '${provider.generatedReminders.length} reminders • ${userData.smartReminders ? 'Smart' : 'Manual'}',
                      icon: Icons.notifications_active_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AquaReminderScreen()),
                      ),
                    ),
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
                          const LivePermissionWarning(),
                          SizedBox(height: 12.h),

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

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: context.colors.primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: context.colors.primaryDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colors.mutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: context.colors.mutedLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    String current,
    bool is24h,
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: is24h),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
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
