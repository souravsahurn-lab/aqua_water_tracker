import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/billing_service.dart';
import '../widgets/top_snackbar.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Consumer<BillingService>(
        builder: (context, billing, _) {
          if (billing.isPremium) {
            return _buildAlreadyPro(context, c);
          }
          return _buildProOffer(context, c, billing);
        },
      ),
    );
  }

  Widget _buildAlreadyPro(BuildContext context, AppColors c) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: c.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(Icons.workspace_premium_rounded, size: 50.w, color: Colors.white),
              ),
              SizedBox(height: 32.h),
              Text(
                'You\'re Aqua Pro! 🎉',
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: c.primaryDark),
              ),
              SizedBox(height: 12.h),
              Text(
                'Thank you for upgrading. All Pro features are unlocked.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: c.mutedLight, height: 1.5),
              ),
              SizedBox(height: 40.h),
              _backButton(context, c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProOffer(BuildContext context, AppColors c, BillingService billing) {
    return Stack(
      children: [
        // Background gradient shimmer
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  c.primary.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: c.primaryDark, size: 20.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        billing.restorePurchases();
                        TopSnackBar.show(context, message: 'Restoring purchases...', type: TopSnackBarType.info);
                      },
                      child: Text('Restore', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: c.primary)),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hero icon
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [c.primary, c.primary.withValues(alpha: 0.7)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(Icons.workspace_premium_rounded, size: 44.w, color: Colors.white),
                      ),
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        'Aqua Pro',
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: c.primaryDark, letterSpacing: -1),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Unlock the full Aqua experience',
                        style: TextStyle(fontSize: 14.sp, color: c.mutedLight),
                      ),
                      SizedBox(height: 36.h),

                      // Features list
                      _featureCard(
                        context,
                        icon: Icons.widgets_rounded,
                        title: '5 Home Screen Widgets',
                        desc: 'Water bar, Hourly graph, Weekly chart, Bottle fill & Quick-add grid — all unlocked for your home screen.',
                        c: c,
                      ),
                      _featureCard(
                        context,
                        icon: Icons.share_rounded,
                        title: 'Share Hydration Data',
                        desc: 'Export and share your daily, weekly or monthly hydration reports with friends or your doctor.',
                        c: c,
                      ),
                      _featureCard(
                        context,
                        icon: Icons.block_rounded,
                        title: 'No Ads — Ever',
                        desc: 'Enjoy a clean, distraction-free experience with zero advertisements. Forever.',
                        c: c,
                      ),
                      _featureCard(
                        context,
                        icon: Icons.favorite_rounded,
                        title: 'Support Development',
                        desc: 'Your purchase directly supports future updates and helps keeping Aqua alive ❤️',
                        c: c,
                      ),
                      SizedBox(height: 32.h),

                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () => billing.buyPremium(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open_rounded, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                billing.products.isNotEmpty
                                    ? 'Upgrade — ${billing.products.first.price}'
                                    : 'Upgrade to Aqua Pro',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Lifetime note
                      Text(
                        'One-time purchase · Lifetime access',
                        style: TextStyle(fontSize: 12.sp, color: c.mutedLight, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureCard(BuildContext context, {required IconData icon, required String title, required String desc, required AppColors c}) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: c.softLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 22.sp, color: c.primary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: c.primaryDark)),
                SizedBox(height: 4.h),
                Text(desc, style: TextStyle(fontSize: 12.sp, color: c.mutedLight, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context, AppColors c) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Text('Back to App', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
