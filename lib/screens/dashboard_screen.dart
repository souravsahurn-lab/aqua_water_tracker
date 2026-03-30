import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/water_bottle.dart';
import '../widgets/top_snackbar.dart';
import '../widgets/live_permission_warning.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showCustomLogPopup(HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomLogBottomSheet(provider: provider),
    );
  }

  void _showLogsSheet(HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LogsBottomSheet(provider: provider),
    );
  }

  void _showEditGoalSheet(HydrationProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditGoalBottomSheet(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final pct = provider.pct;
        final remaining = provider.remaining;
        final userData = provider.userData;
        final logs = provider.todayLogs;

        return Stack(
          children: [
            // ─── Main scrollable content ──────────────────────────
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  // ─── Header ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${provider.getGreeting().replaceAll(',', '')} 👋',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: context.colors.mutedLight,
                              ),
                            ),
                            Text(
                              userData.name.isNotEmpty ? userData.name : 'Friend',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: context.colors.primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const LivePermissionWarning(),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.card,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.warning.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: context.colors.warning.withValues(alpha: 0.15),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text('🔥', style: TextStyle(fontSize: 14.sp)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${provider.displayStreak}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: context.colors.warning,
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

                  // ─── Hero Bottle Section (fills available space) ─
                  Expanded(
                    child: _buildBottleHero(provider, pct, remaining, userData),
                  ),

                  // ─── Pro Mockup Card ─────────────────────────────
                  _buildProCard(context),

                  // ─── Today's Log Inline Card ─────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildLogCard(provider, logs),
                  ),

                  SizedBox(height: 10.h),

                  // ─── Quick Actions + Custom Log ──────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: _buildQuickActions(provider),
                  ),

                  // Space for nav bar
                  SizedBox(height: 100.h + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Bottle Hero — centered bottle with values around it
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBottleHero(
    HydrationProvider provider,
    int pct,
    int remaining,
    dynamic userData,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle
          Text(
            "Today's intake",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.muted,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),

          // Big number + tappable goal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${userData.drunk}',
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colors.primaryDark,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showEditGoalSheet(provider);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '/ ${userData.goal} ml',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.mutedLight,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.edit_rounded,
                      size: 13.sp,
                      color: context.colors.mutedLight,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Bottle
          WaterBottle(
            pct: pct.toDouble(),
            size: 180.h,
          ),

          SizedBox(height: 18.h),

          // Progress pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100.w,
                  height: 5.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      backgroundColor: context.colors.softLight,
                      valueColor: AlwaysStoppedAnimation(context.colors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  remaining <= 0 ? 'Done! 🎉' : '$pct%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: remaining <= 0
                        ? context.colors.success
                        : context.colors.primaryDark,
                  ),
                ),
                if (remaining > 0) ...[
                  Text(
                    '  •  $remaining ml left',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.mutedLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Today's Log — small inline tappable card
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLogCard(HydrationProvider provider, List logs) {
    return Material(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () => _showLogsSheet(provider),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: context.colors.softLight),
          ),
          child: Row(
            children: [
              // Recent log icons (show last 3)
              if (logs.isEmpty)
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    size: 18.sp,
                    color: context.colors.primary,
                  ),
                )
              else
                SizedBox(
                  width: (logs.length.clamp(1, 3) * 24.0 + 8).w,
                  height: 32.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < logs.length.clamp(0, 3); i++)
                        Positioned(
                          left: (i * 20.0).w,
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: context.colors.seafoamLight,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: context.colors.card,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                logs[i].icon,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Log",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    Text(
                      logs.isEmpty
                          ? 'No logs yet'
                          : '${logs.length} entries • Tap to view',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.colors.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${logs.fold<int>(0, (sum, l) => sum + (l.ml as int))} ml',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.mutedLight,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Pro Mockup Card (Slim Professional Widget Promo)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildProCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.warning.withValues(alpha: 0.15),
              context.colors.warning.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: context.colors.warning.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: context.colors.warning,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Pro Widgets Unlocked',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.warning,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Just at \$35 + Tax',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: context.colors.mutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.warning,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Quick Actions — compact row above nav
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildQuickActions(HydrationProvider provider) {
    final items = [
      {'icon': '☕', 'label': 'Cup', 'ml': '100', 'val': 100},
      {'icon': '🥛', 'label': 'Glass', 'ml': '250', 'val': 250},
      {'icon': '🫗', 'label': 'Mug', 'ml': '300', 'val': 300},
      {'icon': '🍶', 'label': 'Bottle', 'ml': '500', 'val': 500},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ADD',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.mutedLight,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // Quick add chips
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: idx == items.length - 1 ? 6.w : 6.w),
                  child: Material(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(14.r),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        provider.drinkWater(
                          item['val'] as int,
                          label: item['label'] as String,
                          icon: item['icon'] as String,
                        );
                        TopSnackBar.show(
                          context,
                          message: '+${item['ml']} ml ${item['label']} added 💦',
                          icon: item['icon'] as String,
                          type: TopSnackBarType.success,
                        );
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.softLight),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item['icon'] as String, style: TextStyle(fontSize: 18.sp)),
                            SizedBox(height: 3.h),
                            Text(
                              '${item['ml']} ml',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Custom log button
            SizedBox(
              width: 48.w,
              height: 48.h,
              child: Material(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCustomLogPopup(provider);
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Edit Goal Bottom Sheet
// ═════════════════════════════════════════════════════════════════════
class _EditGoalBottomSheet extends StatefulWidget {
  final HydrationProvider provider;
  const _EditGoalBottomSheet({required this.provider});

  @override
  State<_EditGoalBottomSheet> createState() => _EditGoalBottomSheetState();
}

class _EditGoalBottomSheetState extends State<_EditGoalBottomSheet> {
  late TextEditingController _goalController;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: '${widget.provider.userData.goal}');
    _isCustom = widget.provider.userData.customGoal;
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommended = widget.provider.recommendedGoal;
    final userData = widget.provider.userData;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w, 20.h, 24.w,
        MediaQuery.of(context).viewInsets.bottom + 30.h,
      ),
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
            'Edit Daily Goal',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 8.h),

          // Recommended goal explanation
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 20.sp, color: context.colors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended: $recommended ml',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Based on ${userData.weight}kg, ${userData.height}cm, ${userData.activity} activity, ${userData.gender}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colors.mutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Goal input
          TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.primaryDark,
            ),
            decoration: InputDecoration(
              labelText: 'Daily Goal (ml)',
              labelStyle: TextStyle(color: context.colors.mutedLight, fontSize: 13.sp),
              suffixText: 'ml',
              suffixStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.mutedLight,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.primary, width: 2),
              ),
            ),
            onChanged: (val) {
              setState(() { _isCustom = true; });
            },
          ),
          SizedBox(height: 16.h),

          // Quick presets
          Text(
            'QUICK SET',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.mutedLight,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [1500, 2000, 2500, 3000, 3500, 4000].map((ml) {
              final isSelected = _goalController.text == '$ml';
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _goalController.text = '$ml';
                    _isCustom = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary.withValues(alpha: 0.12)
                        : context.colors.softLight,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.softLight,
                    ),
                  ),
                  child: Text(
                    '$ml ml',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),

          // Actions
          Row(
            children: [
              // Reset to recommended
              if (_isCustom || userData.customGoal)
                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.provider.resetGoalToRecommended();
                        Navigator.pop(context);
                        TopSnackBar.show(
                          context,
                          message: 'Goal reset to recommended: $recommended ml',
                          type: TopSnackBarType.info,
                        );
                      },
                      icon: Icon(Icons.refresh_rounded, size: 18.sp),
                      label: Text('Reset', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.primary,
                        side: BorderSide(color: context.colors.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isCustom || userData.customGoal) SizedBox(width: 12.w),

              // Save
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final goal = int.tryParse(_goalController.text);
                      if (goal == null || goal < 500) {
                        TopSnackBar.show(
                          context,
                          message: 'Please enter a valid goal (min 500ml)',
                          type: TopSnackBarType.error,
                        );
                        return;
                      }
                      HapticFeedback.lightImpact();
                      widget.provider.updateGoal(goal);
                      Navigator.pop(context);
                      TopSnackBar.show(
                        context,
                        message: 'Daily goal updated to $goal ml 🎯',
                        type: TopSnackBarType.success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Goal',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Logs Bottom Sheet — shown when tapping "Today's Log" card
// ═════════════════════════════════════════════════════════════════════
class _LogsBottomSheet extends StatelessWidget {
  final HydrationProvider provider;
  const _LogsBottomSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<HydrationProvider>(
        builder: (context, provider, _) {
          final logs = provider.todayLogs;
          final maxHeight = MediaQuery.of(context).size.height * 0.65;

          return Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                SizedBox(height: 12.h),
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

                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Log",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: context.colors.primaryDark,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${logs.length} entries',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Log list
                if (logs.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Text('💧', style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          'No logs yet — start drinking!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.colors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        0,
                        24.w,
                        20.h + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: logs.length,
                      itemBuilder: (context, idx) {
                        final log = logs[idx];
                        // Find actual index in full logs list
                        final actualIdx = provider.logs.indexOf(log);
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.bg,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: context.colors.softLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38.w,
                                height: 38.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      context.colors.seafoamLight,
                                      context.colors.softLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    log.icon,
                                    style: TextStyle(fontSize: 17.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                        color: context.colors.text,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      log.time,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: context.colors.mutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '+${log.ml} ml',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    provider.undoDrink(actualIdx >= 0 ? actualIdx : idx);
                                    TopSnackBar.show(
                                      context,
                                      message: 'Log removed',
                                      type: TopSnackBarType.error,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.r),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: context.colors.danger.withValues(alpha: 0.6),
                                      size: 18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

// ═════════════════════════════════════════════════════════════════════
// Custom Log Bottom Sheet
// ═════════════════════════════════════════════════════════════════════
class _CustomLogBottomSheet extends StatefulWidget {
  final HydrationProvider provider;
  const _CustomLogBottomSheet({required this.provider});

  @override
  State<_CustomLogBottomSheet> createState() => _CustomLogBottomSheetState();
}

class _CustomLogBottomSheetState extends State<_CustomLogBottomSheet> {
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();

  final List<Map<String, String>> suggestions = [
    {'icon': '🥛', 'label': 'Milk'},
    {'icon': '☕', 'label': 'Tea'},
    {'icon': '🥤', 'label': 'Smoothie'},
    {'icon': '⚡', 'label': 'Energy'},
    {'icon': '💪', 'label': 'Protein'},
    {'icon': '🥥', 'label': 'Coconut'},
    {'icon': '🍋', 'label': 'Soda'},
  ];

  String selectedIcon = '💧';

  void _submit() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    final label = _labelController.text.isNotEmpty
        ? _labelController.text
        : 'Custom drink';
    HapticFeedback.lightImpact();
    widget.provider.drinkWater(amount, label: label, icon: selectedIcon);
    Navigator.pop(context);
    TopSnackBar.show(
      context,
      message: '+$amount ml $label added 💦',
      icon: selectedIcon,
      type: TopSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        20.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 30.h,
      ),
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
            'Log Custom Drink',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'SUGGESTIONS',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.mutedLight,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestions.map((s) {
                final isSelected = _labelController.text == s['label'];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ActionChip(
                    label: Text(s['label']!),
                    avatar: Text(s['icon']!),
                    onPressed: () {
                      setState(() {
                        _labelController.text = s['label']!;
                        selectedIcon = s['icon']!;
                      });
                    },
                    backgroundColor: isSelected
                        ? context.colors.primary.withValues(alpha: 0.1)
                        : context.colors.card,
                    side: BorderSide(
                      color: isSelected ? context.colors.primary : context.colors.softLight,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? context.colors.primary : context.colors.text,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24.h),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'Drink Name',
              hintText: 'e.g. Protein Shake',
              labelStyle: TextStyle(
                color: context.colors.mutedLight,
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (ml)',
              hintText: 'e.g. 300',
              labelStyle: TextStyle(
                color: context.colors.mutedLight,
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: context.colors.softLight),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add Log',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
