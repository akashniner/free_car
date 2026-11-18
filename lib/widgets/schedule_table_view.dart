import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ScheduleTableView extends StatelessWidget {
  final FinancialPlan plan;
  final int selectedMonth;
  final ValueChanged<int> onMonthSelected;

  const ScheduleTableView({
    super.key,
    required this.plan,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final timeline = plan.generateTimeline();

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
                      child: const Icon(Icons.table_chart, color: AppTheme.electricCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '60-Month Payment & Balance Schedule',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Detailed month-by-month cashflow statement',
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
              Text(
                'Tap row to inspect',
                style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.8), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable table
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 18,
                  headingRowHeight: 40,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 38,
                  headingRowColor: WidgetStateProperty.all(AppTheme.border.withValues(alpha: 0.3)),
                  columns: const [
                    DataColumn(label: Text('Month', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('OD Interest', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('SIP Invested', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('SIP Portfolio', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('OD Principal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Gold Value', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Free Payoff Status', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                  rows: timeline.map((s) {
                    final isCurrent = s.month == selectedMonth;
                    final isPayoff = s.canPayoffOd;

                    return DataRow(
                      selected: isCurrent,
                      onSelectChanged: (_) => onMonthSelected(s.month),
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (isCurrent) return AppTheme.electricCyan.withValues(alpha: 0.15);
                        if (isPayoff) return AppTheme.primaryEmerald.withValues(alpha: 0.08);
                        return null;
                      }),
                      cells: [
                        DataCell(Text('Mo ${s.month}', style: TextStyle(color: isPayoff ? AppTheme.primaryEmerald : AppTheme.textPrimary, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, fontSize: 11.5))),
                        DataCell(Text(CurrencyHelper.format(s.monthlyOdInterest), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5))),
                        DataCell(Text(CurrencyHelper.format(s.cumulativeSipInvested), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5))),
                        DataCell(Text(CurrencyHelper.format(s.sipValuation), style: const TextStyle(color: AppTheme.primaryEmerald, fontWeight: FontWeight.w600, fontSize: 11.5))),
                        DataCell(Text(CurrencyHelper.format(s.odPrincipal), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11.5))),
                        DataCell(Text(CurrencyHelper.format(s.pledgedGoldValue), style: const TextStyle(color: AppTheme.gold, fontSize: 11.5))),
                        DataCell(
                          isPayoff
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('🎉 FREE CAR READY', style: TextStyle(color: AppTheme.primaryEmerald, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              : Text(
                                  '${((s.sipValuation / s.odPrincipal) * 100).toStringAsFixed(0)}% Funded',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
