import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/bar_chart.dart';
import '../widgets/spark_line.dart';
import '../widgets/mini_bar.dart';
import 'package:flutter/services.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HydrationProvider>(
      builder: (context, provider, _) {
        final period = provider.statPeriod;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16.h + MediaQuery.of(context).padding.top, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your hydration insights',
                    style: TextStyle(
                      fontSize: 13.sp, 
                      color: context.colors.mutedLight
                    ),
                  ),
                ],
              ),
            ),

            // Period selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: context.colors.softLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Day', 'Week', 'Month'].map((p) {
                    final isActive = period == p.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        provider.setStatPeriod(p.toLowerCase());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isActive ? context.colors.card : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: context.colors.primary.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? context.colors.primary
                                : context.colors.mutedLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Scrollable cards
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 110.h + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    // Bar chart card
                    _buildCard(context,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                period == 'day'
                                    ? 'Hourly Intake'
                                    : period == 'week'
                                        ? 'Weekly Intake'
                                        : 'Monthly Intake',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: context.colors.primaryDark,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: context.colors.success.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up,
                                        size: 11, color: context.colors.success),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '+18%',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SimpleBarChart(
                            data: provider.getBarData(period),
                            labels: _getBarLabels(period),
                          ),
                          SizedBox(height: 16.h),
                          _buildStatsSummary(context, period),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Trend line card
                    _buildCard(context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trend Line',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          SparkLine(
                            data: provider.getBarData(period),
                            color: context.colors.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Drink breakdown card
                    _buildCard(context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drink Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: context.colors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Builder(builder: (context) {
                            final map = provider.drinkTypeBreakdown;
                            final total = map.values.fold(0, (a, b) => a + b);
                            final max = total == 0 ? 1 : total;
                            return Column(
                              children: [
                                MiniBar(
                                    val: map['Water']!.toDouble(),
                                    max: max.toDouble(),
                                    color: context.colors.primary,
                                    label: 'Water',
                                    sub: total > 0 ? '${(map['Water']! / total * 100).round()}%' : '0%'),
                                MiniBar(
                                    val: map['Tea / Coffee']!.toDouble(),
                                    max: max.toDouble(),
                                    color: context.colors.accent,
                                    label: 'Tea / Coffee',
                                    sub: total > 0 ? '${(map['Tea / Coffee']! / total * 100).round()}%' : '0%'),
                                MiniBar(
                                    val: map['Juice']!.toDouble(),
                                    max: max.toDouble(),
                                    color: context.colors.warning,
                                    label: 'Juice',
                                    sub: total > 0 ? '${(map['Juice']! / total * 100).round()}%' : '0%'),
                                MiniBar(
                                    val: map['Sports drinks']!.toDouble(),
                                    max: max.toDouble(),
                                    color: context.colors.danger,
                                    label: 'Sports drinks',
                                    sub: total > 0 ? '${(map['Sports drinks']! / total * 100).round()}%' : '0%'),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Streak card
                    _buildStreakCard(context, provider),
                    SizedBox(height: 16.h),

                    // Hydration score card
                    _buildScoreCard(context),
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

  Widget _buildStatsSummary(BuildContext context, String period) {
    final stats = period == 'day'
        ? [
            ['💧', '285 ml', 'Avg'],
            ['🏆', '400 ml', 'Best'],
            ['🎯', '—', 'Goal']
          ]
        : period == 'week'
            ? [
                ['💧', '2,048 ml', 'Avg'],
                ['🏆', '2,600 ml', 'Best'],
                ['🎯', '5/7', 'Hit']
              ]
            : [
                ['💧', '2,320 ml', 'Avg'],
                ['🏆', '2,800 ml', 'Best'],
                ['🎯', '22/30', 'Hit']
              ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
            decoration: BoxDecoration(
              color: context.colors.softLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(s[0], style: TextStyle(fontSize: 15.sp)),
                SizedBox(height: 4.h),
                Text(
                  s[1],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: context.colors.primaryDark,
                  ),
                ),
                Text(
                  s[2],
                  style: TextStyle(fontSize: 10.sp, color: context.colors.mutedLight),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakCard(BuildContext context, HydrationProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.06),
            context.colors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: context.colors.seafoam.withValues(alpha: 0.27),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 28,
              color: context.colors.warning,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.userData.streak} Day Streak!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                ),
                Text(
                  "You're on a roll. Keep it up!",
                  style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                    return Container(
                      width: 26.w,
                      height: 26.h,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        gradient: context.colors.primaryGradient,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.check, size: 11, color: Colors.white),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context) {
    return _buildCard(context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hydration Score',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '84',
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.primary,
                      height: 1.h,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(fontSize: 11.sp, color: context.colors.mutedLight),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Great! 🎉',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "You're consistently hitting 80%+ of your daily goal. Aim for 2,500ml to reach 100.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.mutedLight,
                        height: 1.5.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getBarLabels(String period) {
    if (period == 'day') return ['8am', '10', '12', '2pm', '4', '6', '8'];
    if (period == 'week') return ['1', '2', '3', '4', '5', '6', '7'];
    return ['1', '', '2', '', '3', '', '4', '', '5', '', '6', '', ''];
  }
}
