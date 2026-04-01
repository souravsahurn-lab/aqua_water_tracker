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

class _LivePermissionWarningState extends State<LivePermissionWarning> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isChecking = true;
  bool _notif = true;
  bool _alarm = true;
  bool _battery = true;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.15, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
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
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: context.colors.danger.withValues(alpha: _pulseAnimation.value),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: context.colors.danger.withValues(alpha: _pulseAnimation.value + 0.2),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.danger.withValues(alpha: _pulseAnimation.value * 0.5),
                  blurRadius: 8 * _pulseAnimation.value * 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.15).animate(_pulseController),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CRITICAL SETUP NEEDED',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'Missing: $missingStr. Click to fix.',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

