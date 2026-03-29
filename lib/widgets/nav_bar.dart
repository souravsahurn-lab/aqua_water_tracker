import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppNavBar extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChange;

  const AppNavBar({super.key, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(id: 'dashboard', icon: Icons.home_rounded, label: 'Home'),
      _NavItem(id: 'analytics', icon: Icons.bar_chart_rounded, label: 'Stats'),
      _NavItem(id: 'schedule', icon: Icons.access_time_rounded, label: 'Schedule'),
      _NavItem(id: 'settings', icon: Icons.settings_rounded, label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items.map((item) {
                final active = current == item.id;
                return GestureDetector(
                  onTap: () => onChange(item.id),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    padding: EdgeInsets.symmetric(
                      horizontal: active ? 20.w : 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : Colors.transparent,
                      gradient: active ? AppTheme.primaryGradient : null,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24.sp,
                          color: active ? Colors.white : AppTheme.mutedLight,
                        ),
                        if (active) ...[
                          SizedBox(width: 8.w),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final IconData icon;
  final String label;

  _NavItem({required this.id, required this.icon, required this.label});
}
