import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/hydration_provider.dart';
import '../widgets/nav_bar.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Consumer<HydrationProvider>(
        builder: (context, provider, _) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                // If the user is scrolling down, hide the nav bar
                if (notification.scrollDelta! > 2 && _isVisible) {
                  setState(() => _isVisible = false);
                }
                // If the user is scrolling up, show the nav bar
                else if (notification.scrollDelta! < -2 && !_isVisible) {
                  setState(() => _isVisible = true);
                }
              }
              return false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Screen content with smooth transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<String>(provider.activeNav),
                    child: _buildScreen(provider.activeNav),
                  ),
                ),

                // Floating nav bar with auto-hide animation
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuint,
                  left: 20.w,
                  right: 20.w,
                  bottom: _isVisible 
                      ? (16.h + MediaQuery.of(context).padding.bottom) 
                      : -140.h,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isVisible ? 1.0 : 0.0,
                    child: AppNavBar(
                      current: provider.activeNav,
                      onChange: (nav) => provider.setActiveNav(nav),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreen(String activeNav) {
    switch (activeNav) {
      case 'dashboard':
        return DashboardScreen();
      case 'analytics':
        return AnalyticsScreen();
      case 'schedule':
        return ScheduleScreen();
      case 'settings':
        return SettingsScreen();
      default:
        return DashboardScreen();
    }
  }
}
