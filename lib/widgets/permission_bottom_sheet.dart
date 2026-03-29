import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class PermissionBottomSheet extends StatefulWidget {
  final VoidCallback onFinish;
  final int goal;

  const PermissionBottomSheet({
    super.key,
    required this.onFinish,
    required this.goal,
  });

  @override
  State<PermissionBottomSheet> createState() => _PermissionBottomSheetState();
}

class _PermissionBottomSheetState extends State<PermissionBottomSheet> {
  bool _notifGranted = false;
  bool _alarmGranted = false;
  bool _batteryGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final n = await Permission.notification.status.isGranted;
    // Note: scheduleExactAlarm doesn't have a direct 'isGranted' check for older Androids
    // but we can try to check status.
    final a = await Permission.scheduleExactAlarm.status.isGranted;
    final b = await Permission.ignoreBatteryOptimizations.status.isGranted;

    if (mounted) {
      setState(() {
        _notifGranted = n;
        _alarmGranted = a;
        _batteryGranted = b;
      });
    }
  }

  Future<void> _requestNotification() async {
    final s = await Permission.notification.request();
    if (mounted) setState(() => _notifGranted = s.isGranted);
  }

  Future<void> _requestAlarm() async {
    final s = await Permission.scheduleExactAlarm.request();
    if (mounted) setState(() => _alarmGranted = s.isGranted);
  }

  Future<void> _requestBattery() async {
    final s = await Permission.ignoreBatteryOptimizations.request();
    if (mounted) setState(() => _batteryGranted = s.isGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: AppTheme.soft,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: AppTheme.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Permissions',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Optimizing your hydration journey',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            'To ensure you reach your goal, Aqua needs your permission to manage reminders effectively. These are required for the app to function as intended.',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppTheme.text.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 24.h),

          // Goal Display
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.accent,
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This is your Daily Goal',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        '${widget.goal} ml',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          // Permission Header
          Text(
            'Permissions Needed',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),

          // Permission Items
          _PermissionItem(
            title: 'Push Notifications',
            desc: 'Get timely reminders to drink water throughout your day.',
            icon: Icons.notifications_active_rounded,
            isGranted: _notifGranted,
            onTap: _requestNotification,
          ),
          SizedBox(height: 16.h),
          _PermissionItem(
            title: 'Exact Alarms',
            desc: 'Required for high-precision reminders that work even in idle mode.',
            icon: Icons.alarm_rounded,
            isGranted: _alarmGranted,
            onTap: _requestAlarm,
          ),
          SizedBox(height: 16.h),
          _PermissionItem(
            title: 'Background Optimization',
            desc: 'Prevents system from killing Aqua to ensure reminders always trigger.',
            icon: Icons.battery_saver_rounded,
            isGranted: _batteryGranted,
            onTap: _requestBattery,
          ),

          SizedBox(height: 32.h),

          AppButton(
            text: 'I Understand, Let\'s Go!',
            onPressed: widget.onFinish,
          ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton(
              onPressed: widget.onFinish,
              child: Text(
                'Setup Later',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mutedLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGranted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isGranted
              ? AppTheme.success.withValues(alpha: 0.05)
              : AppTheme.softLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isGranted
                ? AppTheme.success.withValues(alpha: 0.2)
                : AppTheme.soft,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isGranted ? AppTheme.success : AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGranted ? Icons.check_rounded : icon,
                color: isGranted ? Colors.white : AppTheme.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (!isGranted)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'ALLOW',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
