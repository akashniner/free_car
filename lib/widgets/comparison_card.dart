import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ComparisonCard extends StatelessWidget {
  final FinancialPlan plan;

  const ComparisonCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final timeline = plan.generateTimeline();
    final finalSnapshot = timeline.last;
    final netGain = finalSnapshot.netWealthSurplus + (finalSnapshot.pledgedGoldValue - plan.initialGoldValueRequired);

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
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows, color: AppTheme.primaryEmerald, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traditional Loan vs Free Vehicle Blueprint',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '60-Month Outcome Comparison',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Comparison side-by-side columns
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 680;
              final colWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Traditional Loan Column
                  SizedBox(
                    width: colWidth,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.debtRed.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Traditional Auto Loan',
                                  style: TextStyle(
                                    color: AppTheme.debtRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.debtRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Liability Trap',
                                  style: TextStyle(
                                    color: AppTheme.debtRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Monthly EMI:',
                            CurrencyHelper.format(plan.traditionalMonthlyEmi),
                          ),
                          _buildDetailRow(
                            'Total Paid (60 Mo):',
                            CurrencyHelper.format(plan.traditionalTotalPaid),
                          ),
                          _buildDetailRow(
                            'Interest Sunk to Bank:',
                            CurrencyHelper.format(plan.traditionalTotalInterest),
                            color: AppTheme.debtRed,
                          ),
                          _buildDetailRow(
                            'Gold Leverage:',
                            'None (Gold lies dormant)',
                          ),
                          _buildDetailRow(
                            'Portfolio Built:',
                            '₹0 (No investment created)',
                          ),
                          const Divider(color: AppTheme.border, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Net Wealth at Mo 60:',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '-${CurrencyHelper.format(plan.traditionalTotalPaid)}',
                                style: const TextStyle(
                                  color: AppTheme.debtRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free Vehicle Blueprint Column
                  SizedBox(
                    width: colWidth,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Free Vehicle (OD + SIP)',
                                  style: TextStyle(
                                    color: AppTheme.primaryEmerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Wealth Engine',
                                  style: TextStyle(
                                    color: AppTheme.primaryEmerald,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Monthly Outflow:',
                            '${CurrencyHelper.format(plan.totalMonthlyOutflow)} (~₹1k OD + ₹2k SIP)',
                            color: AppTheme.primaryEmerald,
                          ),
                          _buildDetailRow(
                            'Total OD Interest (60 Mo):',
                            CurrencyHelper.format(finalSnapshot.cumulativeOdInterest),
                          ),
                          _buildDetailRow(
                            'Total SIP Invested:',
                            CurrencyHelper.format(finalSnapshot.cumulativeSipInvested),
                          ),
                          _buildDetailRow(
                            'Matured SIP Portfolio:',
                            CurrencyHelper.format(finalSnapshot.sipValuation),
                            color: AppTheme.primaryEmerald,
                          ),
                          _buildDetailRow(
                            'Gold Collateral Value:',
                            '${CurrencyHelper.format(finalSnapshot.pledgedGoldValue)} (Safe)',
                            color: AppTheme.gold,
                          ),
                          const Divider(color: AppTheme.border, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Surplus Wealth Generated:',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+${CurrencyHelper.format(netGain)}',
                                style: const TextStyle(
                                  color: AppTheme.primaryEmerald,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
          const SizedBox(height: 16),

          // Bottom Key Insight Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryEmerald.withValues(alpha: 0.15),
                  AppTheme.electricCyan.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Why this strategy makes the vehicle "Free":',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1. You only pay OD interest (~₹1,000/mo) instead of heavy principal amortization.\n'
                        '2. The ₹2,000/mo SIP compounds in equities at ~14%, generating ${CurrencyHelper.format(finalSnapshot.sipValuation)} at Month 60.\n'
                        '3. The SIP fund pays off the full ₹1.5L OD loan with ${CurrencyHelper.format(finalSnapshot.netWealthSurplus)} to spare.\n'
                        '4. Your pledged gold was never sold, and appreciated from ${CurrencyHelper.format(plan.initialGoldValueRequired)} to ${CurrencyHelper.format(finalSnapshot.pledgedGoldValue)}.',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
