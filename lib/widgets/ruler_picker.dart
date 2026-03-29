import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class RulerPicker extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChange;
  final int min;
  final int max;
  final int step;
  final String unit;
  final String label;
  final Color? color;

  const RulerPicker({
    super.key,
    required this.value,
    required this.onChange,
    required this.min,
    required this.max,
    this.step = 1,
    required this.unit,
    required this.label,
    this.color,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late FixedExtentScrollController _controller;
  late List<int> _items;

  @override
  void initState() {
    super.initState();
    _buildItems();
    final idx = _items.indexOf(widget.value);
    _controller = FixedExtentScrollController(initialItem: idx >= 0 ? idx : 0);
  }

  void _buildItems() {
    _items = [];
    for (int v = widget.min; v <= widget.max; v += widget.step) {
      _items.add(v);
    }
  }

  @override
  void didUpdateWidget(RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final idx = _items.indexOf(widget.value);
      if (idx >= 0 && _controller.hasClients) {
        _controller.animateToItem(idx,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.color ?? AppTheme.primary;
    const itemH = 46.0;
    const visibleCount = 5;

    return Column(
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.mutedLight,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: itemH * visibleCount,
          decoration: BoxDecoration(
            color: AppTheme.softLight,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: col.withValues(alpha: 0.13), width: 1.5.w),
          ),
          child: Stack(
            children: [
              // Scroll wheel
              CupertinoPicker.builder(
                scrollController: _controller,
                itemExtent: itemH,
                diameterRatio: 2.5,
                useMagnifier: true,
                magnification: 1.15,
                selectionOverlay: const SizedBox.shrink(),
                onSelectedItemChanged: (index) {
                  widget.onChange(_items[index]);
                },
                childCount: _items.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      '${_items[index]}',
                      style: TextStyle(
                        fontSize: 27.sp,
                        fontWeight: FontWeight.w800,
                        color: col,
                      ),
                    ),
                  );
                },
              ),
              IgnorePointer(
                child: Stack(
                  children: [
                    // Selection band
                    Center(
                      child: Container(
                        height: itemH,
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: col.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: col.withValues(alpha: 0.25), width: 1.5.w),
                        ),
                      ),
                    ),
                    // Tick marks
                    Center(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 7.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.37),
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Container(
                                width: 12.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: col,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Container(
                                width: 7.w,
                                height: 1.5.h,
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.37),
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top fade
                    Positioned(
                      top: 0.h,
                      left: 0.w,
                      right: 0.w,
                      height: itemH * 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.softLight,
                              AppTheme.softLight.withValues(alpha: 0),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Bottom fade
                    Positioned(
                      bottom: 0.h,
                      left: 0.w,
                      right: 0.w,
                      height: itemH * 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(22.r)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.softLight,
                              AppTheme.softLight.withValues(alpha: 0),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          widget.unit,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: col,
          ),
        ),
      ],
    );
  }
}
