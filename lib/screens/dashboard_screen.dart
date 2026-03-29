import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/water_bottle.dart';
import '../widgets/wave_decoration.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final pct = provider.pct;
        final remaining = provider.remaining;
        final userData = provider.userData;

        return SingleChildScrollView(
          child: Column(
            children: [
              // ─── Header ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  16.h + MediaQuery.of(context).padding.top,
                  20.w,
                  0,
                ),
                child: Column(
                  children: [
                    // Greeting row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning 👋',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.mutedLight,
                              ),
                            ),
                            Text(
                              userData.name.isNotEmpty
                                  ? userData.name
                                  : 'Friend',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryDark,
                                letterSpacing: -0.5,
                              ),
                            ),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.warning.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppTheme.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text('🔥', style: TextStyle(fontSize: 14.sp)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${userData.streak}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              width: 44.w,
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppTheme.softLight,
                                  width: 1.w,
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppTheme.primary,
                                size: 22.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Professional Bottle Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppTheme.headerGradient,
                        borderRadius: BorderRadius.circular(32.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: AppTheme.headerGradient.begin,
                                end: AppTheme.headerGradient.end,
                                stops: AppTheme.headerGradient.stops,
                                colors: AppTheme.headerGradient.colors
                                    .map((c) => c.withValues(alpha: 0.92))
                                    .toList(),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Soft decorative elements
                                Positioned(
                                  top: -30.h,
                                  right: -20.w,
                                  child: Container(
                                    width: 140.w,
                                    height: 140.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -40.h,
                                  left: -30.w,
                                  child: Container(
                                    width: 160.w,
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.04,
                                      ),
                                    ),
                                  ),
                                ),
                                // Wave decoration inside the card at the bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: WaveDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    opacity: 1.0,
                                    height: 60.h,
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 28.h,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      WaterBottle(
                                        pct: pct.toDouble(),
                                        size: 140.h,
                                      ),
                                      SizedBox(width: 24.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Today's intake",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  '${userData.drunk}',
                                                  style: TextStyle(
                                                    fontSize: 38.sp,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    letterSpacing: -1,
                                                    height: 1,
                                                  ),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  '/ ${userData.goal} ml',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '$pct% complete',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                                if (remaining <= 0)
                                                  Text(
                                                    'Done! 🎉',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: const Color(
                                                        0xFFFFDC96,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Container(
                                              height: 6.h,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.1),
                                                  width: 0.5.w,
                                                ),
                                              ),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: (pct / 100).clamp(
                                                  0.0,
                                                  1.0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        blurRadius: 6,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
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
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Scrollable content ────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  16.h,
                  20.w,
                  110.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Add section
                    Text(
                      'QUICK ADD',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.mutedLight,
                        letterSpacing: 1.2,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildQuickAddGrid(provider),
                    SizedBox(height: 12.h),

                    // Custom log button
                    _buildCustomLogToggle(provider),
                    SizedBox(height: 12.h),

                    // Today's log
                    _buildTodayLog(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddGrid(HydrationProvider provider) {
    final items = [
      {'icon': '💧', 'label': 'Glass', 'ml': '250 ml', 'val': 250},
      {'icon': '🥤', 'label': 'Bottle', 'ml': '500 ml', 'val': 500},
      {'icon': '☕', 'label': 'Coffee', 'ml': '180 ml', 'val': 180},
      {'icon': '🧃', 'label': 'Juice', 'ml': '330 ml', 'val': 330},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 10.h,
      crossAxisSpacing: 10.w,
      childAspectRatio: 2.7,
      children: items.map((item) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          elevation: 0,
          child: InkWell(
            onTap: () => provider.drinkWater(
              item['val'] as int,
              label: item['label'] as String,
              icon: item['icon'] as String,
            ),
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppTheme.softLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.seafoamLight, AppTheme.softLight],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        item['icon'] as String,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      Text(
                        item['ml'] as String,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.mutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomLogToggle(HydrationProvider provider) {
    return GestureDetector(
      onTap: () => _showCustomLogPopup(provider),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.33),
            width: 1.5.w,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: AppTheme.primary),
            SizedBox(width: 8.w),
            Text(
              'Custom Log',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLog(HydrationProvider provider) {
    final logs = provider.logs;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppTheme.softLight),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Log",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${logs.length} entries',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (logs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No logs yet — start drinking! 💧',
                style: TextStyle(fontSize: 13.sp, color: AppTheme.mutedLight),
              ),
            )
          else
            ...logs.take(5).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final log = entry.value;
              final isLast = idx == (logs.length.clamp(0, 5) - 1);
              return Dismissible(
                key: ValueKey('${log.time}_${log.label}_$idx'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  provider.undoDrink(idx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Log removed',
                        style: TextStyle(fontFamily: 'DM Sans'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.primaryDark,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  margin: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: AppTheme.softLight,
                              width: 1.w,
                            ),
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
                            colors: [AppTheme.seafoamLight, AppTheme.softLight],
                          ),
                          borderRadius: BorderRadius.circular(13.r),
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
                                color: AppTheme.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              log.time,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.mutedLight,
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
                          color: AppTheme.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '+${log.ml} ml',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            provider.undoDrink(idx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Log removed',
                                  style: TextStyle(fontFamily: 'DM Sans'),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.primaryDark,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: Icon(
                              Icons.delete_outline,
                              color: AppTheme.danger.withValues(alpha: 0.7),
                              size: 18.sp,
                            ),
                          ),
                        ),
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
    widget.provider.drinkWater(amount, label: label, icon: selectedIcon);
    Navigator.pop(context);
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
        color: Colors.white,
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
                color: AppTheme.softLight,
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
              color: AppTheme.primaryDark,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'SUGGESTIONS',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.mutedLight,
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
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.softLight,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : AppTheme.text,
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
                color: AppTheme.mutedLight,
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppTheme.softLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppTheme.softLight),
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
                color: AppTheme.mutedLight,
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppTheme.softLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppTheme.softLight),
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
                backgroundColor: AppTheme.primary,
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
