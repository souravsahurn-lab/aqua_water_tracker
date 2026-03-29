import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/app_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final userData = provider.userData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your preferences',
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.mutedLight),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: AppTheme.headerGradient,
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 56.w,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Icon(Icons.person_rounded,
                                    size: 26, color: Colors.white),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData.name.isNotEmpty
                                          ? userData.name
                                          : 'Your Name',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Goal: ${userData.goal} ml/day',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                    Text(
                                      '${userData.weight}kg · ${userData.height}cm · ${userData.activity}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Hydration section
                    _sectionTitle('Hydration'),
                    _buildCard(
                      children: [
                        _settingRow(
                          icon: Icons.gps_fixed_rounded,
                          iconColor: AppTheme.primary,
                          label: 'Daily Goal',
                          value: '${userData.goal} ml',
                        ),
                        _settingRow(
                          icon: null,
                          emoji: '⚖️',
                          label: 'Weight',
                          value: '${userData.weight} kg',
                        ),
                        _settingRow(
                          icon: Icons.bolt_rounded,
                          iconColor: AppTheme.warning,
                          label: 'Activity',
                          value: userData.activity,
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Notifications section
                    _sectionTitle('Notifications'),
                    _buildCard(
                      children: [
                        _toggleRow(
                          icon: Icons.notifications_rounded,
                          iconColor: AppTheme.primary,
                          label: 'Push Reminders',
                          value: userData.reminders,
                          onChanged: provider.toggleReminders,
                        ),
                        _toggleRow(
                          emoji: '🎵',
                          label: 'Sound Alerts',
                          value: userData.sound,
                          onChanged: provider.toggleSound,
                        ),
                        _toggleRow(
                          emoji: '📳',
                          label: 'Vibration',
                          value: userData.vibration,
                          onChanged: provider.toggleVibration,
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Appearance section
                    _sectionTitle('Appearance'),
                    _buildCard(
                      children: [
                        _toggleRow(
                          emoji: '🌙',
                          label: 'Dark Mode',
                          value: userData.darkMode,
                          onChanged: provider.toggleDarkMode,
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // More section
                    _sectionTitle('More'),
                    _buildCard(
                      children: [
                        _settingRow(emoji: '📤', label: 'Export Data', value: 'CSV / PDF'),
                        _settingRow(emoji: '🔒', label: 'Privacy', value: 'Manage'),
                        _settingRow(
                          emoji: 'ℹ️',
                          label: 'App Version',
                          value: '1.0.0',
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Reset button
                    AppButton(
                      text: 'Reset All Data',
                      onPressed: () async {
                        await provider.resetApp();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
                        }
                      },
                      variant: AppButtonVariant.secondary,
                      backgroundColor: AppTheme.danger.withValues(alpha: 0.07),
                      textColor: AppTheme.danger,
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.mutedLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.softLight),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow({
    IconData? icon,
    Color? iconColor,
    String? emoji,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppTheme.softLight, width: 1.w),
              ),
      ),
      child: Row(
        children: [
          if (emoji != null)
            SizedBox(
              width: 24.w,
              child: Text(emoji, style: TextStyle(fontSize: 18.sp)),
            )
          else if (icon != null)
            Icon(icon, size: 18, color: iconColor ?? AppTheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.text,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.mutedLight),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded,
              size: 14, color: AppTheme.mutedLight),
        ],
      ),
    );
  }

  Widget _toggleRow({
    IconData? icon,
    Color? iconColor,
    String? emoji,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppTheme.softLight, width: 1.w),
              ),
      ),
      child: Row(
        children: [
          if (emoji != null)
            SizedBox(
              width: 24.w,
              child: Text(emoji, style: TextStyle(fontSize: 18.sp)),
            )
          else if (icon != null)
            Icon(icon, size: 18, color: iconColor ?? AppTheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: 46.w,
              height: 26.h,
              decoration: BoxDecoration(
                gradient: value ? AppTheme.primaryGradient : null,
                color: value ? null : AppTheme.softLight,
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 250),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
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
          ),
        ],
      ),
    );
  }
}
