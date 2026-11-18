import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class IncomeBudgetCard extends StatelessWidget {
  final FinancialPlan plan;
  final ValueChanged<double> onIncomeChanged;

  const IncomeBudgetCard({
    super.key,
    required this.plan,
    required this.onIncomeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final creditRatio = (plan.vehicleCost / plan.healthyCreditLimit).clamp(0.0, 1.0);
    final isWithinCreditLimit = plan.vehicleCost <= plan.healthyCreditLimit;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.electricCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pie_chart, color: AppTheme.electricCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '40 / 30 / 30 Financial Rule',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Credit capacity & sustainable wealth architecture',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
                  color: isWithinCreditLimit
                      ? AppTheme.primaryEmerald.withValues(alpha: 0.15)
                      : AppTheme.debtRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isWithinCreditLimit ? AppTheme.primaryEmerald : AppTheme.debtRed,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isWithinCreditLimit ? Icons.check_circle : Icons.warning_amber,
                      color: isWithinCreditLimit ? AppTheme.primaryEmerald : AppTheme.debtRed,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isWithinCreditLimit ? 'Healthy Credit' : 'Over Limit',
                      style: TextStyle(
                        color: isWithinCreditLimit ? AppTheme.primaryEmerald : AppTheme.debtRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Monthly Income Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Monthly Net Income:',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyHelper.format(plan.monthlyIncome),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: plan.monthlyIncome,
            min: 25000,
            max: 200000,
            divisions: 35,
            label: CurrencyHelper.formatCompact(plan.monthlyIncome),
            onChanged: onIncomeChanged,
          ),
          const SizedBox(height: 10),

          // 3 Column Breakdown Cards (40%, 30%, 30%)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    _buildAllocationColumn(
                      title: '40% Necessities',
                      amount: plan.necessitiesBudget,
                      subtitle: 'Living, food, rent, bills',
                      accentColor: Colors.blueAccent,
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 8),
                    _buildAllocationColumn(
                      title: '30% Investments',
                      amount: plan.investmentBudget,
                      subtitle: 'SIP & Wealth growth',
                      accentColor: AppTheme.primaryEmerald,
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 8),
                    _buildAllocationColumn(
                      title: '30% Cash Reserve',
                      amount: plan.cashReserveBudget,
                      subtitle: 'Emergency & Collateral',
                      accentColor: AppTheme.gold,
                      icon: Icons.shield,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildAllocationColumn(
                      title: '40% Necessities',
                      amount: plan.necessitiesBudget,
                      subtitle: 'Living, food, rent, bills',
                      accentColor: Colors.blueAccent,
                      icon: Icons.home,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAllocationColumn(
                      title: '30% Investments',
                      amount: plan.investmentBudget,
                      subtitle: 'SIP & Wealth growth',
                      accentColor: AppTheme.primaryEmerald,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAllocationColumn(
                      title: '30% Cash Reserve',
                      amount: plan.cashReserveBudget,
                      subtitle: 'Emergency & Collateral',
                      accentColor: AppTheme.gold,
                      icon: Icons.shield,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Credit Formula Banner (18x of 30%)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.bolt, color: AppTheme.gold, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Healthy Credit Limit (18 × 30% Income)',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyHelper.format(plan.healthyCreditLimit),
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: creditRatio,
                    minHeight: 6,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isWithinCreditLimit ? AppTheme.electricCyan : AppTheme.debtRed,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Vehicle: ${CurrencyHelper.format(plan.vehicleCost)} (${(creditRatio * 100).toStringAsFixed(0)}% of limit)',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Safe: ${CurrencyHelper.format((plan.healthyCreditLimit - plan.vehicleCost).clamp(0, double.infinity))}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(color: AppTheme.primaryEmerald, fontSize: 10.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationColumn({
    required String title,
    required double amount,
    required String subtitle,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyHelper.format(amount),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 9.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
