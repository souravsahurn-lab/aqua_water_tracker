import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'theme/app_theme.dart';
import 'providers/hydration_provider.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'services/billing_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await NotificationService().init();
  await WidgetService.initialize();
  await MobileAds.instance.initialize();

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
  runApp(AquaApp());
}

class AquaApp extends StatelessWidget {
  const AquaApp({super.key});

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
                initialRoute: '/splash',
                routes: {
                  '/splash': (context) => SplashScreen(),
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
