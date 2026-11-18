import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class WealthGrowthChart extends StatefulWidget {
  final FinancialPlan plan;
  final int selectedMonth;
  final ValueChanged<int> onMonthSelected;

  const WealthGrowthChart({
    super.key,
    required this.plan,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<WealthGrowthChart> createState() => _WealthGrowthChartState();
}

class _WealthGrowthChartState extends State<WealthGrowthChart> {
  @override
  Widget build(BuildContext context) {
    final timeline = widget.plan.generateTimeline();
    final maxVal = timeline.map((s) => math.max(s.sipValuation, math.max(s.pledgedGoldValue, s.traditionalCumulativePaid))).reduce(math.max);
    final ceiling = (maxVal * 1.15).clamp(100000.0, 10000000.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.show_chart, color: AppTheme.primaryEmerald, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wealth Trajectory vs Traditional Debt',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Watch SIP cross the OD Debt line to make the vehicle 100% Free',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      'Month ${widget.selectedMonth}',
                      style: const TextStyle(
                        color: AppTheme.electricCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart Canvas
              SizedBox(
                height: 220,
                width: double.infinity,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _handlePointer(details.localPosition, constraints.maxWidth - 32),
                  onTapDown: (details) => _handlePointer(details.localPosition, constraints.maxWidth - 32),
                  child: CustomPaint(
                    painter: _TrajectoryPainter(
                      timeline: timeline,
                      selectedMonth: widget.selectedMonth,
                      maxVal: ceiling,
                      tenureMonths: widget.plan.tenureMonths,
                      vehicleCost: widget.plan.vehicleCost,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Legends
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegend(AppTheme.primaryEmerald, 'SIP Growth (Asset)'),
                  _buildLegend(AppTheme.gold, 'Gold Collateral Value'),
                  _buildLegend(AppTheme.electricCyan, 'OD Principal (Target to clear)'),
                  _buildLegend(AppTheme.debtRed, 'Traditional Loan Sunk Cost'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePointer(Offset localPosition, double width) {
    if (width <= 0) return;
    final pct = (localPosition.dx / width).clamp(0.0, 1.0);
    final month = (pct * widget.plan.tenureMonths).round();
    widget.onMonthSelected(month);
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  final List<MonthSnapshot> timeline;
  final int selectedMonth;
  final double maxVal;
  final int tenureMonths;
  final double vehicleCost;

  _TrajectoryPainter({
    required this.timeline,
    required this.selectedMonth,
    required this.maxVal,
    required this.tenureMonths,
    required this.vehicleCost,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = height - (height * (i / 4));
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);

      final val = maxVal * (i / 4);
      final textSpan = TextSpan(
        text: CurrencyHelper.formatCompact(val),
        style: TextStyle(
          color: AppTheme.textMuted.withValues(alpha: 0.8),
          fontSize: 9,
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(4, y - 12));
    }

    // Coordinates mapping
    Offset pointFor(int month, double value) {
      final x = (month / tenureMonths) * width;
      final y = height - ((value / maxVal) * height).clamp(0.0, height);
      return Offset(x, y);
    }

    // 1. Draw OD Principal Target Line (Horizontal line)
    final odY = height - ((vehicleCost / maxVal) * height).clamp(0.0, height);
    final odLinePaint = Paint()
      ..color = AppTheme.electricCyan.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Dashed line for OD principal
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < width) {
      canvas.drawLine(
        Offset(startX, odY),
        Offset(math.min(startX + dashWidth, width), odY),
        odLinePaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 2. Draw Traditional Loan cumulative paid line (Red)
    final tradPath = Path();
    for (int i = 0; i < timeline.length; i++) {
      final pt = pointFor(timeline[i].month, timeline[i].traditionalCumulativePaid);
      if (i == 0) {
        tradPath.moveTo(pt.dx, pt.dy);
      } else {
        tradPath.lineTo(pt.dx, pt.dy);
      }
    }
    final tradPaint = Paint()
      ..color = AppTheme.debtRed.withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tradPath, tradPaint);

    // 3. Draw Gold Collateral Path (Gold)
    final goldPath = Path();
    for (int i = 0; i < timeline.length; i++) {
      final pt = pointFor(timeline[i].month, timeline[i].pledgedGoldValue);
      if (i == 0) {
        goldPath.moveTo(pt.dx, pt.dy);
      } else {
        goldPath.lineTo(pt.dx, pt.dy);
      }
    }
    final goldPaint = Paint()
      ..color = AppTheme.gold
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(goldPath, goldPaint);

    // 4. Draw SIP Wealth Path with Gradient Fill (Emerald Green)
    final sipPath = Path();
    final sipFillPath = Path();

    for (int i = 0; i < timeline.length; i++) {
      final pt = pointFor(timeline[i].month, timeline[i].sipValuation);
      if (i == 0) {
        sipPath.moveTo(pt.dx, pt.dy);
        sipFillPath.moveTo(pt.dx, height);
        sipFillPath.lineTo(pt.dx, pt.dy);
      } else {
        sipPath.lineTo(pt.dx, pt.dy);
        sipFillPath.lineTo(pt.dx, pt.dy);
      }
    }
    sipFillPath.lineTo(width, height);
    sipFillPath.close();

    final sipFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryEmerald.withValues(alpha: 0.25),
          AppTheme.primaryEmerald.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(sipFillPath, sipFillPaint);

    final sipPaint = Paint()
      ..color = AppTheme.primaryEmerald
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(sipPath, sipPaint);

    // Highlight Crossover Intersection point where SIP >= OD
    for (int i = 1; i < timeline.length; i++) {
      if (timeline[i].sipValuation >= vehicleCost && timeline[i - 1].sipValuation < vehicleCost) {
        final crossPt = pointFor(timeline[i].month, timeline[i].sipValuation);
        final glowPaint = Paint()
          ..color = AppTheme.primaryEmerald.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(crossPt, 12, glowPaint);

        final pinPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(crossPt, 5, pinPaint);
        break;
      }
    }

    // 5. Draw Selected Month Cursor Line
    final selectedX = (selectedMonth / tenureMonths) * width;
    final cursorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(selectedX, 0), Offset(selectedX, height), cursorPaint);

    // Draw dots at selected month for each metric
    final currentSnapshot = timeline[selectedMonth.clamp(0, timeline.length - 1)];
    final sipPt = pointFor(selectedMonth, currentSnapshot.sipValuation);
    final goldPt = pointFor(selectedMonth, currentSnapshot.pledgedGoldValue);

    canvas.drawCircle(sipPt, 5, Paint()..color = AppTheme.primaryEmerald);
    canvas.drawCircle(sipPt, 2, Paint()..color = Colors.white);

    canvas.drawCircle(goldPt, 4, Paint()..color = AppTheme.gold);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) {
    return oldDelegate.selectedMonth != selectedMonth ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.vehicleCost != vehicleCost ||
        oldDelegate.tenureMonths != tenureMonths;
  }
}
