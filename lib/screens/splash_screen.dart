import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/wave_decoration.dart';

import 'package:provider/provider.dart';
import '../providers/hydration_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _floatController;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3200),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _dotController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();

    // Auto-navigate after 2.2 seconds based on setup state
    Future.delayed(Duration(milliseconds: 2200), () {
      if (mounted) {
        final provider = Provider.of<HydrationProvider>(context, listen: false);
        if (provider.isSetupComplete) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _floatController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.colors.splashGradient),
        child: Stack(
          children: [
            // Ripple circles
            ...List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _rippleController,
                builder: (context, _) {
                  final delay = i * 0.22;
                  final progress =
                      ((_rippleController.value + delay) % 1.0);
                  final scale = 0.3 + progress * 1.1;
                  final opacity = (1.0 - progress).clamp(0.0, 1.0);

                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 180.0 * (i + 1),
                        height: 180.0 * (i + 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.09 * opacity),
                            width: 1.w,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating droplet icon
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -8 * _floatController.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 86.w,
                      height: 86.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 48,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // App name
                  Text(
                    'Aqua',
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your hydration companion',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Loading dots
            Positioned(
              bottom: 60.h,
              left: 0.w,
              right: 0.w,
              child: AnimatedBuilder(
                animation: _dotController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final delay = i * 0.17;
                      final opacity =
                          0.3 + 0.7 * (((_dotController.value + delay) % 1.0) < 0.5
                              ? ((_dotController.value + delay) % 1.0) * 2
                              : (1 - ((_dotController.value + delay) % 1.0)) * 2);
                      return Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: opacity),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // Bottom wave
            Positioned(
              bottom: 0.h,
              left: 0.w,
              right: 0.w,
              child: WaveDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                opacity: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
