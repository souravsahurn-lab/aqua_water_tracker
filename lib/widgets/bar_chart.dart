import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SimpleBarChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final int highlightIndex;
  final String? totalLabel;
  /// If provided, bars scale relative to this value (e.g. daily goal).
  /// A bar reaching this value = 100% height. Bars can exceed 100%.
  final double? referenceMax;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.highlightIndex = -1,
    this.totalLabel,
    this.referenceMax,
  });

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.microtask(() => _controller.forward());
  }

  @override
  void didUpdateWidget(covariant SimpleBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use referenceMax if provided, otherwise use the data max
    final dataMax = widget.data.isEmpty
        ? 1.0
        : widget.data.reduce((a, b) => a > b ? a : b);
    // Scale relative to whichever is larger: the reference or the actual max
    // This way bars don't overflow but also show meaningful proportions
    final scaleMax = widget.referenceMax != null
        ? (dataMax > widget.referenceMax! ? dataMax : widget.referenceMax!)
        : dataMax;
    final effectiveMax = scaleMax > 0 ? scaleMax : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total intake label
        if (widget.totalLabel != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.totalLabel!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary,
                ),
              ),
            ),
          ),

        // Bars
        ClipRect(
          child: SizedBox(
          height: 100.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBarH = constraints.maxHeight - 30.h; // Reserve for bottom label + top value label
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(widget.data.length, (i) {
                      final isHighlighted = i == widget.highlightIndex;
                      final fraction = widget.data[i] / effectiveMax;
                      final targetHeight = widget.data[i] > 0
                          ? (fraction * maxBarH).clamp(4.0, maxBarH)
                          : 4.0;

                      // Staggered progressive animation per bar
                      final totalBars = widget.data.length;
                      final barDelay = i / totalBars * 0.35;
                      final barEnd = (barDelay + 0.65).clamp(0.0, 1.0);
                      final interval = Interval(
                        barDelay,
                        barEnd,
                        curve: Curves.easeOutCubic,
                      );
                      final animVal = interval.transform(_controller.value);
                      final barHeight = widget.data[i] > 0
                          ? (targetHeight * animVal).clamp(4.0, maxBarH)
                          : 4.0;

                      // Adaptive horizontal padding based on bar count
                      final hPad = totalBars > 10 ? 1.5.w : (totalBars > 7 ? 2.0.w : 3.0.w);
                      final fontSize = totalBars > 10 ? 7.sp : (totalBars > 7 ? 8.sp : 9.sp);

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Value label on highlighted bar
                              if (isHighlighted && widget.data[i] > 0)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _formatMl(widget.data[i]),
                                      style: TextStyle(
                                        fontSize: 7.sp,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: isHighlighted
                                      ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            context.colors.seafoam,
                                            context.colors.primary,
                                          ],
                                        )
                                      : null,
                                  color: isHighlighted
                                      ? null
                                      : widget.data[i] > 0
                                          ? context.colors.primary.withValues(alpha: 0.25)
                                          : context.colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4.r),
                                    bottom: Radius.circular(2.r),
                                  ),
                                  boxShadow: isHighlighted
                                      ? [
                                          BoxShadow(
                                            color: context.colors.primary.withValues(alpha: 0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.labels[i],
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
                                    color: isHighlighted
                                        ? context.colors.primary
                                        : context.colors.mutedLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),
        ),
        ),
      ],
    );
  }

  String _formatMl(double ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml.round()}ml';
  }
}
