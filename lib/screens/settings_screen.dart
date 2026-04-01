import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/top_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/billing_service.dart';
import 'premium_screen.dart';
import '../widgets/battery_optimization_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                        color: c.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your preferences',
                      style: TextStyle(fontSize: 13.sp, color: c.mutedLight),
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
                    GestureDetector(
                      onTap: () => _showEditProfileSheet(context, provider),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: c.headerGradient,
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
                                        'Goal: ${userData.goal} ml/day${userData.customGoal ? ' (custom)' : ''}',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white.withValues(alpha: 0.75),
                                        ),
                                      ),
                                      Builder(builder: (context) {
                                        final bmi = (userData.weight / ((userData.height / 100) * (userData.height / 100))).toStringAsFixed(1);
                                        return Text(
                                          '${userData.weight}kg · ${userData.height}cm · BMI: $bmi\n${userData.activity}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            height: 1.3,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Premium banner
                    Consumer<BillingService>(
                      builder: (context, billing, _) {
                        if (billing.isPremium) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: GestureDetector(
                              onTap: () => _showProDetails(context, billing.purchaseDate ?? ''),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22.r),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.stars_rounded, color: Colors.amber, size: 28.w),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aqua Pro Activated',
                                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Premium features unlocked ✨',
                                            style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.7)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        'ACTIVE',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.amber),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: c.primaryGradient,
                                borderRadius: BorderRadius.circular(22.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28.w),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upgrade to Aqua Pro',
                                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Unlock Widgets, Share Data & No Ads!',
                                          style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16.w),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Battery optimization configuration card
                    const BatteryOptimizationCard(),

                    // Hydration section
                    _sectionTitle('Hydration', c),
                    _buildCard(
                      c: c,
                      children: [
                        _settingRow(
                          c: c,
                          icon: Icons.gps_fixed_rounded,
                          iconColor: c.primary,
                          label: 'Daily Goal',
                          value: '${userData.goal} ${userData.volumeUnit}',
                          onTap: () => _showEditGoalSheet(context, provider),
                        ),
                        _settingRow(
                          c: c,
                          icon: Icons.local_drink_rounded,
                          iconColor: c.primary,
                          label: 'Volume Unit',
                          value: userData.volumeUnit.toUpperCase(),
                          onTap: () => _showEditVolumeUnitSheet(context, provider),
                        ),
                        _settingRow(
                          c: c,
                          icon: null,
                          emoji: '⚖️',
                          label: 'Weight',
                          value: '${userData.weight} ${userData.weightUnit}',
                          onTap: () => _showEditWeightSheet(context, provider),
                        ),
                        _settingRow(
                          c: c,
                          icon: null,
                          emoji: '📏',
                          label: 'Height',
                          value: '${userData.height} cm',
                          onTap: () => _showEditHeightSheet(context, provider),
                        ),
                        _settingRow(
                          c: c,
                          icon: Icons.bolt_rounded,
                          iconColor: c.warning,
                          label: 'Activity',
                          value: userData.activity,
                          isLast: true,
                          onTap: () => _showEditActivitySheet(context, provider),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Notifications section
                    _sectionTitle('Notifications', c),
                    _buildCard(
                      c: c,
                      children: [
                        _toggleRow(
                          c: c,
                          icon: Icons.notifications_rounded,
                          iconColor: c.primary,
                          label: 'Push Reminders',
                          value: userData.reminders,
                          onChanged: provider.toggleReminders,
                        ),
                        _toggleRow(
                          c: c,
                          emoji: '🎵',
                          label: 'Sound Alerts',
                          value: userData.sound,
                          onChanged: provider.toggleSound,
                        ),
                        _toggleRow(
                          c: c,
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
                    _sectionTitle('Appearance', c),
                    _buildCard(
                      c: c,
                      children: [
                        _toggleRow(
                          c: c,
                          emoji: '🌙',
                          label: 'Dark Mode',
                          value: userData.darkMode,
                          onChanged: provider.toggleDarkMode,
                        ),
                        _toggleRow(
                          c: c,
                          emoji: '⏰',
                          label: '24-hour Time',
                          value: provider.userData.is24HourFormat ?? MediaQuery.of(context).alwaysUse24HourFormat,
                          onChanged: provider.updateIs24HourFormat,
                          isLast: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // More section
                    _sectionTitle('More', c),
                    _buildCard(
                      c: c,
                      children: [
                        Consumer<BillingService>(
                          builder: (context, billing, _) {
                            return _settingRow(
                              c: c,
                              emoji: billing.isPremium ? '📤' : '🔒',
                              label: 'Share Data',
                              value: billing.isPremium ? 'Select' : 'Pro',
                              onTap: () {
                                if (billing.isPremium) {
                                  _showShareSheet(context, provider);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        _settingRow(
                          c: c,
                          emoji: '🔒',
                          label: 'Privacy Policy',
                          value: 'View',
                          onTap: () async {
                            final url = Uri.parse('https://solefate.blogspot.com/p/privacy-policy-for-aqua-water-reminder.html');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        _settingRow(
                          c: c,
                          emoji: '❓',
                          label: 'FAQ & Help',
                          value: 'Open',
                          onTap: () => _showFAQSheet(context),
                        ),
                        _settingRow(
                          c: c,
                          emoji: '📧',
                          label: 'Contact Support',
                          value: 'Email',
                          onTap: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'solefate@gmail.com',
                              queryParameters: {
                                'subject': 'Aqua Water Tracker Support',
                              },
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              await launchUrl(emailLaunchUri);
                            }
                          },
                        ),
                        _settingRow(
                          c: c,
                          emoji: '⭐',
                          label: 'Rate Aqua',
                          value: 'Review',
                          onTap: () async {
                            final url = Uri.parse('market://details?id=com.solefate.aquawatertracker'); // Android Play Store link
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              final webUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.solefate.aquawatertracker');
                              if (await canLaunchUrl(webUrl)) {
                                await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                        ),
                        _settingRow(
                          c: c,
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
                      onPressed: () => _showResetConfirmation(context, provider),
                      variant: AppButtonVariant.secondary,
                      backgroundColor: c.danger.withValues(alpha: 0.07),
                      textColor: c.danger,
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

  // ═══════════════════════════════════════════════════════════════════
  // Edit Profile Sheet
  // ═══════════════════════════════════════════════════════════════════

  void _showEditProfileSheet(BuildContext context, HydrationProvider provider) {
    final nameController = TextEditingController(text: provider.userData.name);
    String selectedGender = provider.userData.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w, height: 4.h,
                    decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                SizedBox(height: 24.h),
                Text('Edit Profile', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
                SizedBox(height: 20.h),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: context.colors.mutedLight, fontSize: 13.sp),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.softLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.softLight)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.primary, width: 2)),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('GENDER', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: context.colors.mutedLight, letterSpacing: 1.2)),
                SizedBox(height: 8.h),
                Row(
                  children: ['male', 'female', 'other'].map((g) {
                    final isSelected = selectedGender == g;
                    final icons = {'male': '👨', 'female': '👩', 'other': '🧑'};
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setSheetState(() { selectedGender = g; });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(right: g != 'other' ? 8.w : 0),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : context.colors.softLight,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isSelected ? context.colors.primary : Colors.transparent),
                          ),
                          child: Column(
                            children: [
                              Text(icons[g]!, style: TextStyle(fontSize: 20.sp)),
                              SizedBox(height: 4.h),
                              Text(g[0].toUpperCase() + g.substring(1), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isSelected ? context.colors.primary : context.colors.text)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (nameController.text.trim().isNotEmpty) {
                        provider.updateName(nameController.text.trim());
                      }
                      provider.updateGender(selectedGender);
                      Navigator.pop(ctx);
                      TopSnackBar.show(context, message: 'Profile updated ✨', type: TopSnackBarType.success);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('Save', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Edit Goal Sheet (reused from dashboard)
  // ═══════════════════════════════════════════════════════════════════

  void _showEditGoalSheet(BuildContext context, HydrationProvider provider) {
    final goalController = TextEditingController(text: '${provider.userData.goal}');
    final recommended = provider.recommendedGoal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Text('Edit Daily Goal', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16.sp, color: context.colors.primary),
                  SizedBox(width: 8.w),
                  Text('Recommended: $recommended ml', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: context.colors.primary)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: context.colors.primaryDark),
              decoration: InputDecoration(
                labelText: 'Daily Goal (ml)',
                suffixText: 'ml',
                labelStyle: TextStyle(color: context.colors.mutedLight, fontSize: 13.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.softLight)),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                if (provider.userData.customGoal)
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: () {
                          provider.resetGoalToRecommended();
                          Navigator.pop(ctx);
                          TopSnackBar.show(context, message: 'Goal reset to $recommended ml', type: TopSnackBarType.info);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primary,
                          side: BorderSide(color: context.colors.primary.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text('Reset', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                if (provider.userData.customGoal) SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final goal = int.tryParse(goalController.text);
                        if (goal == null || goal < 500) {
                          TopSnackBar.show(context, message: 'Min 500ml', type: TopSnackBarType.error);
                          return;
                        }
                        provider.updateGoal(goal);
                        Navigator.pop(ctx);
                        TopSnackBar.show(context, message: 'Goal set to $goal ml 🎯', type: TopSnackBarType.success);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Edit Volume Unit
  // ═══════════════════════════════════════════════════════════════════

  void _showEditVolumeUnitSheet(BuildContext context, HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final units = ['ml', 'oz'];
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
              SizedBox(height: 24.h),
              Text('Volume Unit', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
              SizedBox(height: 16.h),
              Column(
                children: units.map((u) {
                  final isSelected = provider.userData.volumeUnit == u;
                  return GestureDetector(
                    onTap: () {
                      provider.updateVolumeUnit(u);
                      Navigator.pop(ctx);
                      TopSnackBar.show(context, message: 'Unit updated to ${u.toUpperCase()}', type: TopSnackBarType.success);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : context.colors.softLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: isSelected ? context.colors.primary : Colors.transparent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(u.toUpperCase(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isSelected ? context.colors.primary : context.colors.primaryDark)),
                          if (isSelected) Icon(Icons.check_circle_rounded, color: context.colors.primary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Edit Weight
  // ═══════════════════════════════════════════════════════════════════

  void _showEditWeightSheet(BuildContext context, HydrationProvider provider) {
    final controller = TextEditingController(text: '${provider.userData.weight}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Text('Edit Weight', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
            SizedBox(height: 6.h),
            if (!provider.userData.customGoal)
              Text('Changing weight will update your recommended goal', style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight)),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: context.colors.primaryDark),
              decoration: InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
                labelStyle: TextStyle(color: context.colors.mutedLight, fontSize: 13.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.softLight)),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final w = int.tryParse(controller.text);
                  if (w == null || w < 20 || w > 300) {
                    TopSnackBar.show(context, message: 'Enter valid weight (20-300kg)', type: TopSnackBarType.error);
                    return;
                  }
                  provider.updateWeight(w);
                  Navigator.pop(ctx);
                  TopSnackBar.show(context, message: 'Weight updated to $w kg', type: TopSnackBarType.success);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                ),
                child: Text('Save', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Edit Height
  // ═══════════════════════════════════════════════════════════════════

  void _showEditHeightSheet(BuildContext context, HydrationProvider provider) {
    final controller = TextEditingController(text: '${provider.userData.height}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Text('Edit Height', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
            SizedBox(height: 6.h),
            if (!provider.userData.customGoal)
              Text('Changing height will update your recommended goal', style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight)),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: context.colors.primaryDark),
              decoration: InputDecoration(
                labelText: 'Height',
                suffixText: 'cm',
                labelStyle: TextStyle(color: context.colors.mutedLight, fontSize: 13.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: context.colors.softLight)),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final h = int.tryParse(controller.text);
                  if (h == null || h < 100 || h > 250) {
                    TopSnackBar.show(context, message: 'Enter valid height (100-250cm)', type: TopSnackBarType.error);
                    return;
                  }
                  provider.updateHeight(h);
                  Navigator.pop(ctx);
                  TopSnackBar.show(context, message: 'Height updated to $h cm', type: TopSnackBarType.success);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                ),
                child: Text('Save', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Edit Activity
  // ═══════════════════════════════════════════════════════════════════

  void _showEditActivitySheet(BuildContext context, HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final activities = [
          {'key': 'sedentary', 'label': 'Sedentary', 'icon': '🛋️', 'desc': 'Little to no exercise'},
          {'key': 'light', 'label': 'Light', 'icon': '🚶', 'desc': 'Light exercise 1-2 days/week'},
          {'key': 'moderate', 'label': 'Moderate', 'icon': '🏃', 'desc': 'Moderate exercise 3-5 days/week'},
          {'key': 'active', 'label': 'Active', 'icon': '💪', 'desc': 'Hard exercise 6-7 days/week'},
          {'key': 'very active', 'label': 'Very Active', 'icon': '🏋️', 'desc': 'Intense exercise, physical job'},
        ];

        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h + MediaQuery.of(ctx).padding.bottom),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
              SizedBox(height: 24.h),
              Text('Activity Level', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
              SizedBox(height: 6.h),
              if (!provider.userData.customGoal)
                Text('This will update your recommended goal', style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight)),
              SizedBox(height: 16.h),
              ...activities.map((a) {
                final isSelected = provider.userData.activity == a['key'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.updateActivity(a['key'] as String);
                    Navigator.pop(ctx);
                    TopSnackBar.show(context, message: 'Activity: ${a['label']}', type: TopSnackBarType.success);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primary.withValues(alpha: 0.08) : context.colors.bg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? context.colors.primary : context.colors.softLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(a['icon'] as String, style: TextStyle(fontSize: 24.sp)),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['label'] as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: isSelected ? context.colors.primary : context.colors.text)),
                              Text(a['desc'] as String, style: TextStyle(fontSize: 11.sp, color: context.colors.mutedLight)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 22.w, height: 22.h,
                            decoration: BoxDecoration(gradient: context.colors.primaryGradient, shape: BoxShape.circle),
                            child: Icon(Icons.check, size: 12, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Share Data
  // ═══════════════════════════════════════════════════════════════════

  void _showShareSheet(BuildContext context, HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h + MediaQuery.of(ctx).padding.bottom),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Text('Share Hydration Data', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
            Text('Select the period you want to share', style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight)),
            SizedBox(height: 24.h),
            _shareOption(context, provider, 'today', 'Today', '📅'),
            _shareOption(context, provider, 'week', 'Last 7 Days', '🗓️'),
            _shareOption(context, provider, 'month', 'This Month', '📊'),
            _shareOption(context, provider, 'custom', 'Select Specific Day', '🔍'),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(BuildContext context, HydrationProvider provider, String type, String label, String icon) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        DateTime? selectedDate;
        if (type == 'custom') {
          selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: context.colors.primary,
                    onPrimary: Colors.white,
                    onSurface: context.colors.primaryDark,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (selectedDate == null) return;
        }

        final data = provider.getShareData(type, customDate: selectedDate);
        if (data == null) {
          if (context.mounted) {
            TopSnackBar.show(context, message: 'There is no data for this period 📭', type: TopSnackBarType.error);
          }
          return;
        }

        Navigator.pop(context);
        await Share.share(data, subject: 'Aqua Water Tracker Data');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.softLight),
        ),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: context.colors.primaryDark),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.mutedLight),
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════════
  // FAQ Sheet
  // ═══════════════════════════════════════════════════════════════════

  void _showFAQSheet(BuildContext context) {
    final faq = [
      {
        'q': 'Why are my widgets not updating?',
        'a': 'Android\'s battery optimization can sometimes pause background updates. To fix this, please set Aqua to "Unrestricted" in your device\'s Battery settings.'
      },
      {
        'q': 'How does the auto-goal work?',
        'a': 'We calculate your daily goal based on your weight, height, age, and activity level using a personalized scientific formula.'
      },
      {
        'q': 'Are my reminders smart?',
        'a': 'Yes! Regular reminders pause automatically during your sleep window (set in schedule) and only resume when you wake up.'
      },
      {
        'q': 'How to sync data between widgets?',
        'a': 'All widgets sync instantly when you add or remove water in the app. If they seem stuck, open the app once to force a refresh.'
      },
      {
        'q': 'What is Aqua Pro?',
        'a': 'Aqua Pro is a lifetime upgrade that unlocks 5 unique home widgets, data sharing, and removes all advertisements.'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Text('FAQ & Help', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: context.colors.primaryDark)),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: faq.length,
                itemBuilder: (ctx, i) => Theme(
                  data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.only(bottom: 16.h),
                    title: Text(
                      faq[i]['q']!,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: context.colors.primaryDark),
                    ),
                    children: [
                      Text(
                        faq[i]['a']!,
                        style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reset Confirmation
  // ═══════════════════════════════════════════════════════════════════

  void _showResetConfirmation(BuildContext context, HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h + MediaQuery.of(ctx).padding.bottom),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: context.colors.softLight, borderRadius: BorderRadius.circular(10.r)))),
            SizedBox(height: 24.h),
            Icon(Icons.warning_amber_rounded, size: 48.sp, color: context.colors.danger),
            SizedBox(height: 16.h),
            Text('Reset All Data?', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: context.colors.primaryDark)),
            SizedBox(height: 8.h),
            Text(
              'This will permanently delete all your hydration data, preferences, and profile. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight, height: 1.5),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.text,
                        side: BorderSide(color: context.colors.softLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(ctx);
                        await provider.resetApp();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                      child: Text('Reset', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // UI Helpers
  // ═══════════════════════════════════════════════════════════════════

  void _showProDetails(BuildContext context, String purchaseDateIso) {
    DateTime? date;
    try {
      if (purchaseDateIso.isNotEmpty) {
        date = DateTime.parse(purchaseDateIso);
      }
    } catch (_) {}
    final dateStr = date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Recently';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 60.sp),
                  SizedBox(height: 16.h),
                  Text('Aqua Pro', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Lifetime License', style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  _proFeatureRow(context, Icons.widgets_rounded, 'Home Screen Widgets', 'Full access to all sizes & styles'),
                  _proFeatureRow(context, Icons.share_rounded, 'Advanced Sharing', 'CSV & PDF hydration reports'),
                  _proFeatureRow(context, Icons.do_not_disturb_on_rounded, 'No Advertisements', '100% clean and focused experience'),
                  _proFeatureRow(context, Icons.sync_rounded, 'Priority Sync', 'Instant widget & data updates'),
                  Divider(height: 32.h, color: context.colors.softLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status:', style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight)),
                      Text('Active', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Activated On:', style: TextStyle(fontSize: 13.sp, color: context.colors.mutedLight)),
                      Text(dateStr, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: context.colors.text)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: Text('Great!', style: TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _proFeatureRow(BuildContext context, IconData icon, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: context.colors.primary, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: context.colors.text)),
                Text(desc, style: TextStyle(fontSize: 11.sp, color: context.colors.mutedLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, AppColors c) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: c.mutedLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required AppColors c, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: c.softLight),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow({
    required AppColors c,
    IconData? icon,
    Color? iconColor,
    String? emoji,
    required String label,
    required String value,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null ? () {
        HapticFeedback.lightImpact();
        onTap();
      } : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: c.softLight, width: 1.w),
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
              Icon(icon, size: 18, color: iconColor ?? c.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: c.text,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: c.mutedLight),
            ),
            SizedBox(width: 4.w),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 14, color: c.mutedLight),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required AppColors c,
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
                bottom: BorderSide(color: c.softLight, width: 1.w),
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
            Icon(icon, size: 18, color: iconColor ?? c.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: c.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46.w,
              height: 26.h,
              decoration: BoxDecoration(
                gradient: value ? c.primaryGradient : null,
                color: value ? null : c.softLight,
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: c.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
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
