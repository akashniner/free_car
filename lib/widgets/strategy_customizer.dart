import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class StrategyCustomizer extends StatelessWidget {
  final FinancialPlan plan;
  final ValueChanged<FinancialPlan> onPlanChanged;

  const StrategyCustomizer({
    super.key,
    required this.plan,
    required this.onPlanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.purpleAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: AppTheme.purpleAccent, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strategy & Parameter Controls',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Customize vehicle cost, OD rate, and SIP investment',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle Cost Slider
          _buildSliderRow(
            title: 'Vehicle Purchase Price',
            currentValueText: CurrencyHelper.format(plan.vehicleCost),
            min: 50000,
            max: 1000000,
            divisions: 95,
            value: plan.vehicleCost,
            accentColor: AppTheme.electricCyan,
            onChanged: (val) => onPlanChanged(plan.copyWith(vehicleCost: val)),
            helperText: 'e.g. ₹1.5 Lakh for Electric Scooter, or customize for cars',
          ),
          const SizedBox(height: 16),

          // Monthly SIP Slider
          _buildSliderRow(
            title: 'Monthly SIP Investment',
            currentValueText: CurrencyHelper.format(plan.monthlySipAmount),
            min: 1000,
            max: 20000,
            divisions: 38,
            value: plan.monthlySipAmount,
            accentColor: AppTheme.primaryEmerald,
            onChanged: (val) => onPlanChanged(plan.copyWith(monthlySipAmount: val)),
            helperText: 'Invested into diversified index / equity mutual funds',
          ),
          const SizedBox(height: 16),

          // Overdraft Interest Rate Slider
          _buildSliderRow(
            title: 'Gold Overdraft Interest Rate',
            currentValueText: '${plan.odInterestRateAnnual.toStringAsFixed(1)}% p.a.',
            min: 6.0,
            max: 12.0,
            divisions: 12,
            value: plan.odInterestRateAnnual,
            accentColor: AppTheme.gold,
            onChanged: (val) => onPlanChanged(plan.copyWith(odInterestRateAnnual: val)),
            helperText:
                'Monthly OD Interest = ${CurrencyHelper.format(plan.monthlyOdInterest)}/month',
          ),
          const SizedBox(height: 16),

          // Expected SIP Return Rate Slider
          _buildSliderRow(
            title: 'Expected Equity SIP CAGR Return',
            currentValueText: '${plan.sipReturnRateAnnual.toStringAsFixed(1)}% p.a.',
            min: 10.0,
            max: 18.0,
            divisions: 16,
            value: plan.sipReturnRateAnnual,
            accentColor: AppTheme.primaryEmerald,
            onChanged: (val) => onPlanChanged(plan.copyWith(sipReturnRateAnnual: val)),
            helperText: 'Long term equity historical CAGR (12% - 15%)',
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required String currentValueText,
    required double min,
    required double max,
    required int divisions,
    required double value,
    required Color accentColor,
    required ValueChanged<double> onChanged,
    required String helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentValueText,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: accentColor,
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Text(helperText, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}
