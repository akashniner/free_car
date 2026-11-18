import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/comparison_card.dart';
import '../widgets/income_budget_card.dart';
import '../widgets/journey_timeline_view.dart';
import '../widgets/schedule_table_view.dart';
import '../widgets/strategy_customizer.dart';
import '../widgets/variable_input_list.dart';
import '../widgets/wealth_growth_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late FinancialPlan _plan;
  int _selectedMonth = 60;

  @override
  void initState() {
    super.initState();
    _plan = FinancialPlan();
    _selectedMonth = _plan.payoffMonth;
  }

  void _resetToDefault() {
    setState(() {
      _plan = FinancialPlan();
      _selectedMonth = _plan.payoffMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _plan.generateTimeline();
    final snapshot = timeline[_selectedMonth.clamp(0, timeline.length - 1)];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryEmerald, AppTheme.electricCyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.electric_scooter, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREE VEHICLE BLUEPRINT',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '40/30/30 Rule • Gold OD • ₹2,000 Parallel SIP',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to Default Strategy (₹1.5L Scooter)',
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: _resetToDefault,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Summary Strip
                _buildHeroStatsStrip(snapshot),
                const SizedBox(height: 20),

                // 1. Dynamic Variables & Input Studio (with calculated numbers list)
                VariableInputList(
                  plan: _plan,
                  onPlanChanged: (newPlan) {
                    setState(() {
                      _plan = newPlan;
                      if (_selectedMonth > _plan.tenureMonths) {
                        _selectedMonth = _plan.tenureMonths;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 2. The Interactive 60-Month Journey Simulator
                JourneyTimelineView(
                  plan: _plan,
                  selectedMonth: _selectedMonth,
                  onMonthChanged: (m) => setState(() => _selectedMonth = m),
                ),
                const SizedBox(height: 20),

                // 2. Trajectory Chart
                WealthGrowthChart(
                  plan: _plan,
                  selectedMonth: _selectedMonth,
                  onMonthSelected: (m) => setState(() => _selectedMonth = m),
                ),
                const SizedBox(height: 20),

                // 3. 40/30/30 Financial Plan & 18x Credit Multiplier
                IncomeBudgetCard(
                  plan: _plan,
                  onIncomeChanged: (income) {
                    setState(() => _plan = _plan.copyWith(monthlyIncome: income));
                  },
                ),
                const SizedBox(height: 20),

                // 4. Strategy Controls (Tuning parameters)
                StrategyCustomizer(
                  plan: _plan,
                  onPlanChanged: (newPlan) {
                    setState(() {
                      _plan = newPlan;
                      if (_selectedMonth > _plan.tenureMonths) {
                        _selectedMonth = _plan.tenureMonths;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 5. Traditional Auto Loan vs Free Vehicle Comparison
                ComparisonCard(plan: _plan),
                const SizedBox(height: 20),

                // 6. Detailed 60-Month Schedule Table
                ScheduleTableView(
                  plan: _plan,
                  selectedMonth: _selectedMonth,
                  onMonthSelected: (m) => setState(() => _selectedMonth = m),
                ),
                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Text(
                    'Free Vehicle Blueprint • Powered by Disciplined Credit Architecture & Equity Compounding',
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStatsStrip(MonthSnapshot snapshot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceElevated,
            AppTheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;

          final items = [
            _buildHeroItem(
              title: 'Vehicle Cost',
              value: CurrencyHelper.format(_plan.vehicleCost),
              subtitle: 'Electric Scooter',
              icon: Icons.electric_scooter,
              color: AppTheme.electricCyan,
            ),
            _buildHeroItem(
              title: 'Monthly Outflow',
              value: CurrencyHelper.format(_plan.totalMonthlyOutflow),
              subtitle: '${CurrencyHelper.format(_plan.monthlyOdInterest)} OD + ${CurrencyHelper.format(_plan.monthlySipAmount)} SIP',
              icon: Icons.payments,
              color: AppTheme.gold,
            ),
            _buildHeroItem(
              title: 'Payoff Milestone',
              value: 'Month ${_plan.payoffMonth}',
              subtitle: 'SIP covers full ₹1.5L OD',
              icon: Icons.flag,
              color: AppTheme.primaryEmerald,
            ),
            _buildHeroItem(
              title: 'Gold Protected',
              value: CurrencyHelper.format(snapshot.pledgedGoldValue),
              subtitle: 'Appreciating collateral',
              icon: Icons.security,
              color: AppTheme.gold,
            ),
          ];

          if (isCompact) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items.map((w) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: w)).toList(),
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((w) => Expanded(child: w)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildHeroItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
