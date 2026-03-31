import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/bar_chart.dart';

import '../widgets/mini_bar.dart';
import '../widgets/month_calendar.dart';
import '../widgets/daily_log_inline.dart';
import 'package:flutter/services.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();

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
                    if (period == 'month') ...[
                      // Month Calendar
                      _buildCard(context,
                        child: MonthCalendar(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Daily log inline view IF period == 'month'
                      DailyLogInline(date: _selectedDate),
                      SizedBox(height: 16.h),
                    ] else ...[
                      // Bar chart card
                      _buildCard(context,
                        child: Builder(builder: (context) {
                          final barData = provider.getBarData(period);
                          final total = barData.fold(0.0, (a, b) => a + b);
                          final goal = provider.userData.goal.toDouble();

                          // Dynamic labels & highlight from provider
                          final labels = period == 'day'
                              ? provider.getHourlyLabels()
                              : _getWeekLabels();
                          final highlightIdx = period == 'day'
                              ? provider.getHourlyHighlightIndex()
                              : (DateTime.now().weekday == 7 ? 0 : DateTime.now().weekday);

                          // Reference max: scale to the full daily goal, even for hourly bars.
                          // Reference max: scale to the full daily goal, even for hourly bars.
                          final refMax = goal;

                          List<Color>? barColors;
                          if (period == 'week') {
                            final goals = provider.getWeeklyGoals();
                            barColors = List.generate(barData.length, (i) {
                                final intake = barData[i];
                                final dayGoal = i < goals.length ? goals[i] : goal;
                                final pct = dayGoal > 0 ? (intake / dayGoal * 100) : 0;
                                
                                if (pct >= 100) return context.colors.success;
                                if (pct >= 75) return const Color(0xFF4ADE80);
                                if (pct >= 50) return const Color(0xFFFBBF24);
                                if (pct >= 25) return const Color(0xFFF97316);
                                return context.colors.danger;
                            });
                          }

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    period == 'day'
                                        ? 'Hourly Intake'
                                        : 'Weekly Intake',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: context.colors.primaryDark,
                                    ),
                                  ),
                                  _buildTrendBadge(context, provider, period),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              SimpleBarChart(
                                data: barData,
                                labels: labels,
                                highlightIndex: highlightIdx,
                                totalLabel: period == 'day' ? null : 'Total: ${_formatTotalMl(total)}',
                                referenceMax: refMax,
                                barColors: barColors,
                              ),
                              SizedBox(height: 16.h),
                              _buildStatsSummary(context, provider, period),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 16.h),
                    ],



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
                            final map = provider.getDrinkTypeBreakdown(period, _selectedDate);
                            final total = map.values.fold(0, (a, b) => a + b);
                            final max = total == 0 ? 1 : total;
                            
                            if (map.isEmpty) {
                               return Padding(
                                 padding: EdgeInsets.symmetric(vertical: 20.h),
                                 child: Center(
                                   child: Text('No drinks logged yet.', style: TextStyle(color: context.colors.mutedLight, fontSize: 12.sp)),
                                 ),
                               );
                            }

                            final List<Color> palette = [context.colors.primary, context.colors.accent, context.colors.warning, context.colors.danger, context.colors.seafoam];
                            int colorIdx = 0;

                            return Column(
                              children: map.entries.map((entry) {
                                final color = palette[colorIdx % palette.length];
                                colorIdx++;
                                return MiniBar(
                                    val: entry.value.toDouble(),
                                    max: max.toDouble(),
                                    color: color,
                                    label: entry.key,
                                    sub: total > 0 ? '${entry.value} ml (${(entry.value / total * 100).round()}%)' : '0 ml');
                              }).toList(),
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
                    _buildScoreCard(context, provider),
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

  Widget _buildTrendBadge(BuildContext context, HydrationProvider provider, String period) {
    final trend = provider.getTrendPercentage(period);
    final isPositive = trend >= 0;
    final hasData = trend != 0;

    if (!hasData) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: context.colors.softLight,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'No prev data',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: context.colors.mutedLight,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isPositive
            ? context.colors.success.withValues(alpha: 0.09)
            : context.colors.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 11,
            color: isPositive ? context.colors.success : context.colors.danger,
          ),
          SizedBox(width: 4.w),
          Text(
            '${isPositive ? '+' : ''}${trend.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: isPositive ? context.colors.success : context.colors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, HydrationProvider provider, String period) {
    String formatMl(int ml) {
      if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
      return '$ml ml';
    }

    final List<List<String>> stats;

    if (period == 'day') {
      stats = [
        ['💧', formatMl(provider.userData.drunk), 'Total'],
        ['🔔', provider.nextReminderTimeStr, 'Next Reminder'],
      ];
    } else {
      final avg = provider.getAverageIntake(period);
      final best = provider.getBestIntake(period);
      final goalHit = provider.getGoalHitStr(period);

      stats = [
        ['💧', formatMl(avg), 'Avg'],
        ['🏆', formatMl(best), 'Best'],
        ['🎯', goalHit, 'Hit'],
      ];
    }

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
    final weekStatus = provider.weeklyGoalStatus;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final displayStreak = provider.displayStreak;

    String streakMessage;
    if (displayStreak == 0) {
      streakMessage = "Start your streak! Hit today's goal.";
    } else if (displayStreak == 1) {
      streakMessage = "Great start! Keep going tomorrow.";
    } else if (displayStreak < 7) {
      streakMessage = "You're on a roll. Keep it up!";
    } else {
      streakMessage = "Incredible consistency! 🌟";
    }

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
                  '$displayStreak Day Streak${displayStreak > 0 ? '!' : ''}',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                ),
                Text(
                  streakMessage,
                  style: TextStyle(fontSize: 12.sp, color: context.colors.mutedLight),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: List.generate(7, (i) {
                    final met = weekStatus[i];
                    
                    // Calculate color for dot based on progress
                    final now = DateTime.now();
                    final diff = now.weekday == 7 ? 0 : now.weekday;
                    final sunday = now.subtract(Duration(days: diff));
                    final date = sunday.add(Duration(days: i)).toIso8601String().split('T')[0];
                    final intake = provider.logs.where((l) => l.date == date).fold(0, (p, c) => p + c.ml);
                    final dayGoal = provider.userData.goalForDate(date);
                    final pct = dayGoal > 0 ? (intake / dayGoal * 100) : 0;
                    
                    Color dotColor;
                    if (met) {
                      dotColor = context.colors.success;
                    } else if (pct >= 75) {
                      dotColor = const Color(0xFF4ADE80);
                    } else if (pct >= 50) {
                      dotColor = const Color(0xFFFBBF24);
                    } else if (pct >= 25) {
                      dotColor = const Color(0xFFF97316);
                    } else if (intake > 0) {
                      dotColor = context.colors.danger;
                    } else {
                      dotColor = context.colors.softLight;
                    }

                    final isFuture = sunday.add(Duration(days: i)).isAfter(now);
                    final finalColor = isFuture ? context.colors.softLight : dotColor;

                    return Container(
                      width: 26.w,
                      height: 26.h,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        color: finalColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: (finalColor == context.colors.softLight) ? Border.all(
                          color: context.colors.muted.withValues(alpha: 0.2),
                          width: 1,
                        ) : null,
                        boxShadow: !isFuture && intake > 0 ? [
                           BoxShadow(color: finalColor.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                        ] : null,
                      ),
                      child: Center(
                        child: met
                            ? const Icon(Icons.check, size: 11, color: Colors.white)
                            : Text(
                                days[i],
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: finalColor == context.colors.softLight ? context.colors.mutedLight : Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, HydrationProvider provider) {
    final score = provider.hydrationScore;
    final label = provider.hydrationScoreLabel;
    final tip = provider.hydrationScoreTip;

    Color scoreColor;
    if (score >= 70) {
      scoreColor = context.colors.success;
    } else if (score >= 50) {
      scoreColor = context.colors.primary;
    } else if (score >= 30) {
      scoreColor = context.colors.warning;
    } else {
      scoreColor = context.colors.danger;
    }

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
                    '$score',
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                      height: 1,
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
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.mutedLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Score breakdown bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6.h,
              backgroundColor: context.colors.softLight,
              valueColor: AlwaysStoppedAnimation(scoreColor),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consistency + completion + streak',
                style: TextStyle(fontSize: 10.sp, color: context.colors.mutedLight),
              ),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _getWeekLabels() {
    final now = DateTime.now();
    final diff = now.weekday == 7 ? 0 : now.weekday;
    final sunday = now.subtract(Duration(days: diff));
    final dayChars = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    List<String> labels = [];
    for (int i = 0; i < 7; i++) {
        final d = sunday.add(Duration(days: i));
        labels.add('${dayChars[i]}\n${d.day}');
    }
    return labels;
  }

  String _formatTotalMl(double ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml.round()} ml';
  }


}
