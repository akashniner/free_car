import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class JourneyTimelineView extends StatelessWidget {
  final FinancialPlan plan;
  final int selectedMonth;
  final ValueChanged<int> onMonthChanged;

  const JourneyTimelineView({
    super.key,
    required this.plan,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeline = plan.generateTimeline();
    final snapshot = timeline[selectedMonth.clamp(0, timeline.length - 1)];
    final isPayoffAchieved = snapshot.canPayoffOd;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPayoffAchieved
              ? AppTheme.primaryEmerald.withValues(alpha: 0.6)
              : AppTheme.border,
          width: isPayoffAchieved ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Play/Scrub info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.two_wheeler, color: AppTheme.gold, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '60-Month Free Vehicle Journey',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gold Overdraft + ₹2,000 Parallel SIP Strategy',
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPayoffAchieved
                        ? [AppTheme.primaryEmerald, const Color(0xFF059669)]
                        : [AppTheme.electricCyan, const Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPayoffAchieved ? 'FREE SCOOTER WON!' : CurrencyHelper.formatMonth(selectedMonth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Big Month Selector Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Timeline Journey:',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Month $selectedMonth / ${plan.tenureMonths}',
                style: const TextStyle(
                  color: AppTheme.electricCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: isPayoffAchieved ? AppTheme.primaryEmerald : AppTheme.electricCyan,
              thumbColor: isPayoffAchieved ? AppTheme.primaryEmerald : AppTheme.electricCyan,
            ),
            child: Slider(
              value: selectedMonth.toDouble(),
              min: 0,
              max: plan.tenureMonths.toDouble(),
              divisions: plan.tenureMonths,
              onChanged: (val) => onMonthChanged(val.round()),
            ),
          ),

          // Milestone Quick-Jump Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMilestonePill(0, 'Day 1: Start'),
                const SizedBox(width: 8),
                _buildMilestonePill(12, 'Yr 1 (Mo 12)'),
                const SizedBox(width: 8),
                _buildMilestonePill(36, 'Yr 3 (Mo 36)'),
                const SizedBox(width: 8),
                _buildMilestonePill(plan.payoffMonth, 'Payoff (Mo ${plan.payoffMonth})', isHighlight: true),
                const SizedBox(width: 8),
                _buildMilestonePill(60, 'Finish (Mo 60)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic Status Banner at selected month
          if (isPayoffAchieved)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryEmerald.withValues(alpha: 0.25),
                    AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryEmerald, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration, color: AppTheme.primaryEmerald, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VEHICLE FULLY PAID FOR FREE!',
                          style: TextStyle(
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your SIP portfolio has grown to ${CurrencyHelper.format(snapshot.sipValuation)}! You can fully repay the ₹${CurrencyHelper.format(plan.vehicleCost)} OD principal, keep ${CurrencyHelper.format(snapshot.netWealthSurplus)} surplus cash, and reclaim your 100% appreciated gold collateral (${CurrencyHelper.format(snapshot.pledgedGoldValue)})!',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timelapse, color: AppTheme.electricCyan, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SIP is compounding! Currently at ${CurrencyHelper.format(snapshot.sipValuation)} (${((snapshot.sipValuation / plan.vehicleCost) * 100).toStringAsFixed(1)}% of OD debt). Free payoff occurs around Month ${plan.payoffMonth}.',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // 4 Grid KPI Cards for current month
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final itemWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Card 1: SIP Valuation (Growth)
                  SizedBox(
                    width: itemWidth,
                    child: _buildMetricCard(
                      title: 'SIP Portfolio Value',
                      value: CurrencyHelper.format(snapshot.sipValuation),
                      subtext:
                          '${CurrencyHelper.format(snapshot.cumulativeSipInvested)} invested (${CurrencyHelper.format(snapshot.sipValuation - snapshot.cumulativeSipInvested)} gain)',
                      icon: Icons.trending_up,
                      accentColor: AppTheme.primaryEmerald,
                      badge: '+${((snapshot.cumulativeSipInvested > 0 ? ((snapshot.sipValuation - snapshot.cumulativeSipInvested) / snapshot.cumulativeSipInvested) * 100 : 0)).toStringAsFixed(0)}% return',
                    ),
                  ),

                  // Card 2: Gold Collateral Value (Intact & Appreciating)
                  SizedBox(
                    width: itemWidth,
                    child: _buildMetricCard(
                      title: 'Pledged Gold Value',
                      value: CurrencyHelper.format(snapshot.pledgedGoldValue),
                      subtext:
                          'Safely held in bank. Appreciated from ${CurrencyHelper.format(plan.initialGoldValueRequired)}',
                      icon: Icons.shield,
                      accentColor: AppTheme.gold,
                      badge: 'Collateral Safe',
                    ),
                  ),

                  // Card 3: Overdraft Interest Paid
                  SizedBox(
                    width: itemWidth,
                    child: _buildMetricCard(
                      title: 'OD Monthly & Total Interest',
                      value: CurrencyHelper.format(snapshot.cumulativeOdInterest),
                      subtext:
                          'Paid ${CurrencyHelper.format(snapshot.monthlyOdInterest)}/mo interest only (Principal ₹1.5L remains intact)',
                      icon: Icons.receipt_long,
                      accentColor: AppTheme.electricCyan,
                      badge: '~₹1k/mo',
                    ),
                  ),

                  // Card 4: Net Worth Delta vs Traditional Loan
                  SizedBox(
                    width: itemWidth,
                    child: _buildMetricCard(
                      title: 'Net Wealth Position',
                      value: snapshot.canPayoffOd
                          ? '+${CurrencyHelper.format(snapshot.netWealthSurplus + (snapshot.pledgedGoldValue - plan.initialGoldValueRequired))}'
                          : '${CurrencyHelper.format(snapshot.sipValuation - snapshot.odPrincipal)} (Equity gap)',
                      subtext:
                          'Traditional loan paid ${CurrencyHelper.format(snapshot.traditionalCumulativePaid)} with ₹0 assets left',
                      icon: Icons.account_balance_wallet,
                      accentColor: snapshot.canPayoffOd ? AppTheme.primaryEmerald : AppTheme.purpleAccent,
                      badge: snapshot.canPayoffOd ? 'Surplus' : 'Accumulating',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonePill(int month, String label, {bool isHighlight = false}) {
    final isSelected = selectedMonth == month;
    return InkWell(
      onTap: () => onMonthChanged(month),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighlight ? AppTheme.primaryEmerald : AppTheme.electricCyan)
              : (isHighlight
                  ? AppTheme.primaryEmerald.withValues(alpha: 0.15)
                  : AppTheme.surfaceElevated),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight ? AppTheme.primaryEmerald : AppTheme.border,
            width: isHighlight ? 1 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isHighlight ? AppTheme.primaryEmerald : AppTheme.textSecondary),
            fontSize: 10.5,
            fontWeight: isSelected || isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
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
                    Icon(icon, color: accentColor, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: accentColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
