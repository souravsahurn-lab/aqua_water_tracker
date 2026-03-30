import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import 'permission_bottom_sheet.dart';
import '../providers/hydration_provider.dart';
import 'package:provider/provider.dart';

class LivePermissionWarning extends StatefulWidget {
  const LivePermissionWarning({super.key});

  @override
  State<LivePermissionWarning> createState() => _LivePermissionWarningState();
}

class _LivePermissionWarningState extends State<LivePermissionWarning> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _notif = true;
  bool _alarm = true;
  bool _battery = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final n = await Permission.notification.isGranted;
    final a = await Permission.scheduleExactAlarm.isGranted;
    final b = await Permission.ignoreBatteryOptimizations.isGranted;

    if (mounted) {
      setState(() {
        _notif = n;
        _alarm = a;
        _battery = b;
        _isChecking = false;
      });
    }
  }

  void _showPermissionSheet() {
    final provider = context.read<HydrationProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PermissionBottomSheet(
        onFinish: () {
          Navigator.pop(context);
          _checkPermissions();
        },
        goal: provider.userData.goal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) return const SizedBox.shrink();

    // If all granted, show nothing
    if (_notif && _alarm && _battery) {
      return const SizedBox.shrink();
    }

    final missing = <String>[];
    if (!_notif) missing.add('Notifications');
    if (!_alarm) missing.add('Alarms');
    if (!_battery) missing.add('Battery Opt.');

    final missingStr = missing.join(', ');

    return GestureDetector(
      onTap: _showPermissionSheet,
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: context.colors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: context.colors.danger.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 14.sp,
              color: context.colors.danger,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup Incomplete',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.danger,
                    ),
                  ),
                  Text(
                    'Missing: $missingStr. Tap to fix.',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.danger.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
