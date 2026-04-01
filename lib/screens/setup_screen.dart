import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/hydration_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/permission_bottom_sheet.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const _steps = ['name', 'gender', 'stats', 'activity', 'schedule'];
  static const _stepMeta = {
    'name': {
      'title': "What's your name?",
      'sub': "Let's personalize your experience",
      'why':
          "We use your name to personalize your dashboard and notifications, making the tracker feel like your own.",
    },
    'gender': {
      'title': 'Your gender',
      'sub': 'Helps us calculate hydration needs',
      'why':
          "Biological makeup affects how much water your body retains and requires throughout the day.",
    },
    'stats': {
      'title': 'Your vitals',
      'sub': 'Used to calculate your daily hydration goal',
      'why':
          "Age, weight, and height are essential metrics for us to accurately calculate your personalized daily hydration goal.",
    },
    'activity': {
      'title': 'Activity level',
      'sub': 'How active are you daily?',
      'why':
          "Active individuals sweat more and need extra fluid intake to safely replenish lost water and electrolytes.",
    },
    'schedule': {
      'title': 'Your routine',
      'sub': 'When should we remind you?',
      'why':
          "We sync reminders to your schedule so we can gently remind you to drink without ever disturbing your sleep.",
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Consumer<HydrationProvider>(
        builder: (context, provider, _) {
          final stepIdx = provider.setupStep;
          final step = _steps[stepIdx];
          final totalSteps = _steps.length;
          final prog = ((stepIdx + 1) / totalSteps);
          final meta = _stepMeta[step]!;

          return Stack(
            children: [
              // Progress bar at top
              Positioned(
                top: 0.h,
                left: 0.w,
                right: 0.w,
                height: 3.h,
                child: Container(
                  color: context.colors.softLight,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: prog,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [context.colors.primary, context.colors.accent],
                        ),
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button
                      Row(
                        children: [
                          if (stepIdx > 0)
                            GestureDetector(
                              onTap: () => provider.prevSetupStep(),
                              child: Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 28,
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Step ${stepIdx + 1} of $totalSteps',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.mutedLight,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.danger.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        'REQUIRED',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w900,
                                          color: context.colors.danger,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  meta['title']!,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.primaryDark,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  meta['sub']!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: context.colors.mutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Step dots
                      Row(
                        children: List.generate(totalSteps, (i) {
                          return Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 4.h,
                              margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                              decoration: BoxDecoration(
                                gradient: i <= stepIdx
                                    ? LinearGradient(
                                        colors: [
                                          context.colors.primary,
                                          context.colors.accent,
                                        ],
                                      )
                                    : null,
                                color: i <= stepIdx ? null : context.colors.softLight,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 24.h),

                      // Step content
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: _buildStepContent(context, step, provider),
                          ),
                        ),
                      ),

                      // Informational Card
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: context.colors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: context.colors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Why we ask',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.primaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    meta['why']!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      height: 1.4,
                                      color: context.colors.primaryDark.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Continue button
                      SizedBox(height: 18.h),
                      Column(
                        children: [
                          if (!provider.isStepValid)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Text(
                                'Please complete this step to continue',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.danger,
                                ),
                              ),
                            ),
                          Opacity(
                            opacity: provider.isStepValid ? 1.0 : 0.6,
                            child: AppButton(
                              text: stepIdx == totalSteps - 1
                                  ? 'Start My Journey →'
                                  : 'Continue →',
                              onPressed: provider.isStepValid
                                  ? () {
                                      if (stepIdx < totalSteps - 1) {
                                        provider.nextSetupStep();
                                      } else {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          enableDrag: false,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              PermissionBottomSheet(
                                                goal: provider.userData.goal,
                                                onFinish: () {
                                                  provider.completeSetup();
                                                  Navigator.of(
                                                    context,
                                                  ).pushReplacementNamed(
                                                    '/home',
                                                  );
                                                },
                                              ),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    String step,
    HydrationProvider provider,
  ) {
    switch (step) {
      case 'name':
        return _buildNameStep(context, provider);
      case 'gender':
        return _buildGenderStep(context, provider);
      case 'stats':
        return _StatsStepWidget(provider: provider);
      case 'activity':
        return _buildActivityStep(context, provider);
      case 'schedule':
        return _ScheduleStepWidget(provider: provider);
      default:
        return SizedBox();
    }
  }

  Widget _buildNameStep(BuildContext context, HydrationProvider provider) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.colors.seafoamLight, context.colors.softLight],
            ),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Icon(Icons.person_rounded, size: 40, color: context.colors.primary),
        ),
        SizedBox(height: 20.h),
        TextField(
          onChanged: provider.updateName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: context.colors.primaryDark,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Alex',
            hintStyle: TextStyle(
              color: context.colors.mutedLight.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
            filled: true,
            fillColor: context.colors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: context.colors.soft, width: 2.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: context.colors.soft, width: 2.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: context.colors.primary, width: 2.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderStep(BuildContext context, HydrationProvider provider) {
    final genders = [
      {'val': 'male', 'emoji': '👨', 'label': 'Male'},
      {'val': 'female', 'emoji': '👩', 'label': 'Female'},
      {'val': 'other', 'emoji': '🧑', 'label': 'Other'},
    ];

    return Row(
      children: genders.map((g) {
        final isSelected = provider.userData.gender == g['val'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () => provider.updateGender(g['val']!),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: isSelected ? null : context.colors.card,
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colors.primary.withValues(alpha: 0.09),
                            context.colors.accent.withValues(alpha: 0.07),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected ? context.colors.primary : context.colors.softLight,
                    width: isSelected ? 2.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? context.colors.primary.withValues(alpha: 0.13)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: isSelected ? 24 : 12,
                      offset: Offset(0, isSelected ? 8 : 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(g['emoji']!, style: TextStyle(fontSize: 36.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      g['label']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? context.colors.primary : context.colors.text,
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: context.colors.primaryGradient,
                        ),
                        child: Icon(Icons.check, size: 11, color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityStep(BuildContext context, HydrationProvider provider) {
    final activities = [
      {
        'val': 'sedentary',
        'icon': '🪑',
        'label': 'Sedentary',
        'desc': 'Mostly sitting, desk work',
      },
      {
        'val': 'moderate',
        'icon': '🚶',
        'label': 'Moderate',
        'desc': 'Some walking, light exercise',
      },
      {
        'val': 'active',
        'icon': '🏃',
        'label': 'Active',
        'desc': 'Regular workouts & movement',
      },
      {
        'val': 'athlete',
        'icon': '⚡',
        'label': 'Athlete',
        'desc': 'Intense daily training',
      },
    ];

    return Column(
      children: activities.map((a) {
        final isSelected = provider.userData.activity == a['val'];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: GestureDetector(
            onTap: () => provider.updateActivity(a['val']!),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? null : context.colors.card,
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.colors.primary.withValues(alpha: 0.08),
                          context.colors.accent.withValues(alpha: 0.06),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isSelected ? context.colors.primary : context.colors.softLight,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? context.colors.primary.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: isSelected ? 20 : 8,
                    offset: Offset(0, isSelected ? 6 : 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary.withValues(alpha: 0.09)
                          : context.colors.softLight,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text(
                        a['icon']!,
                        style: TextStyle(fontSize: 22.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['label']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.text,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          a['desc']!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.colors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: context.colors.primaryGradient,
                      ),
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatsStepWidget extends StatefulWidget {
  final HydrationProvider provider;
  const _StatsStepWidget({required this.provider});

  @override
  State<_StatsStepWidget> createState() => _StatsStepWidgetState();
}

class _StatsStepWidgetState extends State<_StatsStepWidget> {
  String weightUnit = 'kg';
  String heightUnit = 'cm';

  late TextEditingController ageCtrl;
  late TextEditingController weightCtrl;
  late TextEditingController heightCtrl;

  @override
  void initState() {
    super.initState();
    weightUnit = widget.provider.userData.weightUnit;
    ageCtrl = TextEditingController(text: '${widget.provider.userData.age}');
    weightCtrl = TextEditingController(
      text: '${widget.provider.userData.weight}',
    );
    heightCtrl = TextEditingController(
      text: '${widget.provider.userData.height}',
    );
  }

  @override
  void dispose() {
    ageCtrl.dispose();
    weightCtrl.dispose();
    heightCtrl.dispose();
    super.dispose();
  }

  void _updateWeight() {
    final w = double.tryParse(weightCtrl.text);
    if (w != null && w > 0) {
      final kg = weightUnit == 'lbs' ? (w / 2.20462).round() : w.round();
      widget.provider.updateWeight(kg);
      widget.provider.updateWeightUnit(weightUnit);
    }
  }

  void _updateHeight() {
    final h = double.tryParse(heightCtrl.text);
    if (h != null && h > 0) {
      final cm = heightUnit == 'in' ? (h * 2.54).round() : h.round();
      widget.provider.updateHeight(cm);
    }
  }

  void _updateAge() {
    final a = int.tryParse(ageCtrl.text);
    if (a != null && a > 0) widget.provider.updateAge(a);
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
    required String unitLabel,
    List<String>? unitOptions,
    String? currentUnit,
    ValueChanged<String?>? onUnitChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.primaryDark,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    filled: true,
                    fillColor: context.colors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: context.colors.soft, width: 2.w),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: context.colors.soft, width: 2.w),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 2.w,
                      ),
                    ),
                  ),
                ),
              ),
              if (unitOptions != null) ...[
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentUnit,
                      dropdownColor: context.colors.card,
                      borderRadius: BorderRadius.circular(12.r),
                      items: unitOptions
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                u,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          onUnitChanged?.call(val);
                          onChanged(); // update with new unit
                        }
                      },
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(width: 12.w),
                Container(
                  width: 80.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                    color: context.colors.softLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    unitLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colors.mutedLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputRow(
          label: 'Age',
          controller: ageCtrl,
          onChanged: _updateAge,
          unitLabel: 'yrs',
        ),
        _buildInputRow(
          label: 'Weight',
          controller: weightCtrl,
          onChanged: _updateWeight,
          unitLabel: '',
          unitOptions: ['kg', 'lbs'],
          currentUnit: weightUnit,
          onUnitChanged: (v) {
            setState(() {
              if (weightUnit == 'kg' && v == 'lbs') {
                final w = double.tryParse(weightCtrl.text);
                if (w != null) {
                  weightCtrl.text = (w * 2.20462).round().toString();
                }
              } else if (weightUnit == 'lbs' && v == 'kg') {
                final w = double.tryParse(weightCtrl.text);
                if (w != null) {
                  weightCtrl.text = (w / 2.20462).round().toString();
                }
              }
              weightUnit = v!;
            });
          },
        ),
        _buildInputRow(
          label: 'Height',
          controller: heightCtrl,
          onChanged: _updateHeight,
          unitLabel: '',
          unitOptions: ['cm', 'in'],
          currentUnit: heightUnit,
          onUnitChanged: (v) {
            setState(() {
              if (heightUnit == 'cm' && v == 'in') {
                final h = double.tryParse(heightCtrl.text);
                if (h != null) heightCtrl.text = (h / 2.54).round().toString();
              } else if (heightUnit == 'in' && v == 'cm') {
                final h = double.tryParse(heightCtrl.text);
                if (h != null) heightCtrl.text = (h * 2.54).round().toString();
              }
              heightUnit = v!;
            });
          },
        ),
      ],
    );
  }
}

class _ScheduleStepWidget extends StatelessWidget {
  final HydrationProvider provider;
  const _ScheduleStepWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        _buildTimeTile(
          context,
          'Wake Up Time',
          '🌅',
          provider.userData.wakeTime,
          (time) => provider.updateWakeTime(time),
        ),
        SizedBox(height: 16.h),
        _buildTimeTile(
          context,
          'Bed Time',
          '🌙',
          provider.userData.sleepTime,
          (time) => provider.updateSleepTime(time),
        ),
      ],
    );
  }

  Widget _buildTimeTile(
    BuildContext context,
    String label,
    String icon,
    String time,
    Function(String) onSave,
  ) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final current = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 7,
          minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: current,
        );
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          onSave('$hh:$mm');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: context.colors.softLight, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: context.colors.softLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: 24.sp)),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryDark,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.edit_rounded, color: context.colors.mutedLight, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
