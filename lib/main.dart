import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/hydration_provider.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'services/billing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Non-blocking initialization of heavy services
  NotificationService().init();
  WidgetService.initialize();
  MobileAds.instance.initialize();

  // Fast-read setup status to decide initial route
  final prefs = await SharedPreferences.getInstance();
  final isSetupComplete = prefs.getBool('isSetupComplete') ?? false;

  // Use edgeToEdge as the primary mode to prevent 'black bar' glitches
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );
  runApp(AquaApp(isSetupComplete: isSetupComplete));
}

class AquaApp extends StatelessWidget {
  final bool isSetupComplete;
  const AquaApp({super.key, required this.isSetupComplete});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HydrationProvider()),
        ChangeNotifierProvider(create: (_) => BillingService()..init()),
      ],
      child: ScreenUtilInit(
        designSize: Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<HydrationProvider>(
            builder: (context, provider, _) {
              final isDark = provider.userData.darkMode;
              final appColors = isDark ? AppTheme.dark : AppTheme.light;
              return MaterialApp(
                title: 'Aqua - Water Tracker',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: isDark ? Brightness.dark : Brightness.light,
                  colorSchemeSeed: appColors.primary,
                  textTheme: GoogleFonts.dmSansTextTheme(
                    ThemeData(brightness: isDark ? Brightness.dark : Brightness.light).textTheme,
                  ),
                  scaffoldBackgroundColor: appColors.bg,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                      systemNavigationBarColor: Colors.transparent,
                      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                      systemNavigationBarContrastEnforced: false,
                      systemStatusBarContrastEnforced: false,
                    ),
                  ),
                  extensions: [appColors],
                ),
                initialRoute: isSetupComplete ? '/home' : '/onboarding',
                routes: {
                  '/onboarding': (context) => OnboardingScreen(),
                  '/setup': (context) => SetupScreen(),
                  '/home': (context) => HomeScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
