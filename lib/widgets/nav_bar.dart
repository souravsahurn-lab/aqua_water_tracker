import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topRadius = BorderRadius.only(
      topLeft: Radius.circular(28.r),
      topRight: Radius.circular(28.r),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: topRadius,
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryDark.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: topRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.card.withValues(alpha: isDark ? 0.7 : 0.82),
              borderRadius: topRadius,
              border: Border.all(
                color: context.colors.primaryLight.withValues(alpha: isDark ? 0.12 : 0.25),
                width: 1,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 68.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: items.map((item) {
                    final active = current == item.id;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onChange(item.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 68.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: active ? 1.08 : 0.95,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: active ? context.colors.primary.withValues(alpha: 0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 26.sp,
                                  color: active ? context.colors.primary : context.colors.mutedLight,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutQuint,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                                color: active ? context.colors.primary : context.colors.mutedLight,
                                height: 1,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
