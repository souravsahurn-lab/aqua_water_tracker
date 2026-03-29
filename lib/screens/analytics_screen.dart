import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/bar_chart.dart';
import '../widgets/spark_line.dart';
import '../widgets/mini_bar.dart';

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
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your hydration insights',
                    style: TextStyle(
                      fontSize: 13.sp, 
                      color: AppTheme.mutedLight
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
                  color: AppTheme.softLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Day', 'Week', 'Month'].map((p) {
                    final isActive = period == p.toLowerCase();
                    return GestureDetector(
                      onTap: () => provider.setStatPeriod(p.toLowerCase()),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.12),
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
                                ? AppTheme.primary
                                : AppTheme.mutedLight,
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
                    _buildCard(
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
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up,
                                        size: 11, color: AppTheme.success),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '+18%',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SimpleBarChart(
                            data: _getBarData(period),
                            labels: _getBarLabels(period),
                          ),
                          SizedBox(height: 16.h),
                          _buildStatsSummary(period),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Trend line card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trend Line',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          SparkLine(
                            data: _getTrendData(period),
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Drink breakdown card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drink Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          MiniBar(
                              val: 1400,
                              max: 2500,
                              color: AppTheme.primary,
                              label: 'Water',
                              sub: '56%'),
                          MiniBar(
                              val: 500,
                              max: 2500,
                              color: AppTheme.accent,
                              label: 'Tea / Coffee',
                              sub: '20%'),
                          MiniBar(
                              val: 360,
                              max: 2500,
                              color: AppTheme.warning,
                              label: 'Juice',
                              sub: '14%'),
                          MiniBar(
                              val: 240,
                              max: 2500,
                              color: AppTheme.danger,
                              label: 'Sports drinks',
                              sub: '10%'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Streak card
                    _buildStreakCard(),
                    SizedBox(height: 16.h),

                    // Hydration score card
                    _buildScoreCard(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
      child: child,
    );
  }

  Widget _buildStatsSummary(String period) {
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
              color: AppTheme.softLight,
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
                    color: AppTheme.primaryDark,
                  ),
                ),
                Text(
                  s[2],
                  style: TextStyle(fontSize: 10.sp, color: AppTheme.mutedLight),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.06),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.seafoam.withValues(alpha: 0.27),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 28,
              color: AppTheme.warning,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 Day Streak!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                  ),
                ),
                Text(
                  "You're on a roll. Keep it up!",
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.mutedLight),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                    return Container(
                      width: 26.w,
                      height: 26.h,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
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

  Widget _buildScoreCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hydration Score',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppTheme.primaryDark,
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
                      color: AppTheme.primary,
                      height: 1.h,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.mutedLight),
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
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "You're consistently hitting 80%+ of your daily goal. Aim for 2,500ml to reach 100.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.mutedLight,
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

  List<double> _getBarData(String period) {
    if (period == 'day') return [200, 300, 180, 400, 250, 180, 290];
    if (period == 'week') return [1800, 2100, 2400, 1950, 2600, 2200, 1290];
    return [2100, 1950, 2300, 2450, 2200, 2500, 2350, 2600, 2400, 2700, 2500, 2800, 1290];
  }

  List<String> _getBarLabels(String period) {
    if (period == 'day') return ['8am', '10', '12', '2pm', '4', '6', '8'];
    if (period == 'week') return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ['W1', '', 'W2', '', 'W3', '', 'W4', '', 'W5', '', 'W6', '', ''];
  }

  List<double> _getTrendData(String period) {
    if (period == 'day') return [200, 300, 180, 400, 250, 180, 290];
    if (period == 'week') return [1800, 2100, 2400, 1950, 2600, 2200, 1290];
    return [1600, 1800, 2000, 1700, 2100, 2300, 2200, 2400, 2500, 2300, 2600, 2400, 2500, 2200, 2600, 2800, 2500, 2700, 2600, 2900, 2800, 2600, 2750, 2800, 2600, 2900, 2700, 2500, 2800, 1290];
  }
}
