import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Consumer<HydrationProvider>(
        builder: (context, provider, _) {
          return Stack(
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
                  layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren,
                        ?currentChild,
                      ],
                    );
                  },
                  child: SizedBox.expand(
                    key: ValueKey<String>(provider.activeNav),
                    child: _buildScreen(provider.activeNav),
                  ),
                ),

                // Constant modern full-width nav bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppNavBar(
                    current: provider.activeNav,
                    onChange: (nav) => provider.setActiveNav(nav),
                  ),
                ),
              ],
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
