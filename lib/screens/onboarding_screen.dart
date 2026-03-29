import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardPage(
      icon: Icons.water_drop,
      iconColor: AppTheme.primary,
      bgColor: AppTheme.seafoam,
      title: 'Stay Hydrated,\nStay Healthy',
      body:
          'Your body is 60% water. Smart reminders help you maintain optimal hydration every day.',
      filled: true,
    ),
    _OnboardPage(
      icon: Icons.notifications_active_rounded,
      iconColor: AppTheme.accent,
      bgColor: AppTheme.accent,
      title: 'Smart Reminders\nJust for You',
      body:
          'Personalized reminders based on your schedule, activity level, and hydration goals.',
      filled: false,
    ),
    _OnboardPage(
      icon: Icons.bar_chart_rounded,
      iconColor: AppTheme.warning,
      bgColor: AppTheme.warning,
      title: 'Track Your\nProgress Daily',
      body:
          'Beautiful analytics show your hydration streaks, patterns, and health improvements over time.',
      filled: false,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/setup');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (p) => setState(() => _currentPage = p),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon circle
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: Stack(
                            children: [
                              // Outer radial
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.seafoamLight,
                                      AppTheme.bg,
                                    ],
                                  ),
                                ),
                              ),
                              // Inner radial with icon
                              Center(
                                child: Container(
                                  width: 160.w,
                                  height: 160.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        page.bgColor.withValues(alpha: 0.33),
                                        AppTheme.primaryLight
                                            .withValues(alpha: 0.13),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size: page.filled ? 80 : 72,
                                    color: page.iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28.h),
                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                            height: 1.2.h,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Body
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.mutedLight,
                            height: 1.7.h,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: i == _currentPage ? 24 : 8,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color:
                        i == _currentPage ? AppTheme.primary : AppTheme.soft,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
            SizedBox(height: 28.h),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  AppButton(
                    text: _currentPage == 2 ? 'Complete Setup →' : 'Next →',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String body;
  final bool filled;

  _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.body,
    this.filled = false,
  });
}
