import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class VariableInputList extends StatefulWidget {
  final FinancialPlan plan;
  final ValueChanged<FinancialPlan> onPlanChanged;

  const VariableInputList({
    super.key,
    required this.plan,
    required this.onPlanChanged,
  });

  @override
  State<VariableInputList> createState() => _VariableInputListState();
}

class _VariableInputListState extends State<VariableInputList> {
  late TextEditingController _incomeCtrl;
  late TextEditingController _vehicleCostCtrl;
  late TextEditingController _tenureCtrl;
  late TextEditingController _odRateCtrl;
  late TextEditingController _sipAmountCtrl;
  late TextEditingController _sipCagrCtrl;
  late TextEditingController _goldApprCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _incomeCtrl = TextEditingController(text: widget.plan.monthlyIncome.round().toString());
    _vehicleCostCtrl = TextEditingController(text: widget.plan.vehicleCost.round().toString());
    _tenureCtrl = TextEditingController(text: widget.plan.tenureMonths.toString());
    _odRateCtrl = TextEditingController(text: widget.plan.odInterestRateAnnual.toStringAsFixed(1));
    _sipAmountCtrl = TextEditingController(text: widget.plan.monthlySipAmount.round().toString());
    _sipCagrCtrl = TextEditingController(text: widget.plan.sipReturnRateAnnual.toStringAsFixed(1));
    _goldApprCtrl = TextEditingController(text: widget.plan.goldAppreciationAnnual.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(covariant VariableInputList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _updateTextIfDifferent(_incomeCtrl, widget.plan.monthlyIncome.round().toString());
      _updateTextIfDifferent(_vehicleCostCtrl, widget.plan.vehicleCost.round().toString());
      _updateTextIfDifferent(_tenureCtrl, widget.plan.tenureMonths.toString());
      _updateTextIfDifferent(_odRateCtrl, widget.plan.odInterestRateAnnual.toStringAsFixed(1));
      _updateTextIfDifferent(_sipAmountCtrl, widget.plan.monthlySipAmount.round().toString());
      _updateTextIfDifferent(_sipCagrCtrl, widget.plan.sipReturnRateAnnual.toStringAsFixed(1));
      _updateTextIfDifferent(_goldApprCtrl, widget.plan.goldAppreciationAnnual.toStringAsFixed(1));
    }
  }

  void _updateTextIfDifferent(TextEditingController ctrl, String newText) {
    if (ctrl.text != newText && double.tryParse(ctrl.text) != double.tryParse(newText)) {
      ctrl.text = newText;
    }
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _vehicleCostCtrl.dispose();
    _tenureCtrl.dispose();
    _odRateCtrl.dispose();
    _sipAmountCtrl.dispose();
    _sipCagrCtrl.dispose();
    _goldApprCtrl.dispose();
    super.dispose();
  }

  void _applyChanges() {
    final income = double.tryParse(_incomeCtrl.text) ?? widget.plan.monthlyIncome;
    final vehicleCost = double.tryParse(_vehicleCostCtrl.text) ?? widget.plan.vehicleCost;
    final tenure = int.tryParse(_tenureCtrl.text) ?? widget.plan.tenureMonths;
    final odRate = double.tryParse(_odRateCtrl.text) ?? widget.plan.odInterestRateAnnual;
    final sipAmount = double.tryParse(_sipAmountCtrl.text) ?? widget.plan.monthlySipAmount;
    final sipCagr = double.tryParse(_sipCagrCtrl.text) ?? widget.plan.sipReturnRateAnnual;
    final goldAppr = double.tryParse(_goldApprCtrl.text) ?? widget.plan.goldAppreciationAnnual;

    widget.onPlanChanged(widget.plan.copyWith(
      monthlyIncome: income.clamp(10000, 10000000),
      vehicleCost: vehicleCost.clamp(10000, 50000000),
      tenureMonths: tenure.clamp(12, 120),
      odInterestRateAnnual: odRate.clamp(1.0, 30.0),
      monthlySipAmount: sipAmount.clamp(500, 1000000),
      sipReturnRateAnnual: sipCagr.clamp(1.0, 35.0),
      goldAppreciationAnnual: goldAppr.clamp(0.0, 30.0),
    ));
  }

  void _applyPreset({
    required double vehicleCost,
    required double sipAmount,
    required int tenureMonths,
    required double income,
  }) {
    widget.onPlanChanged(widget.plan.copyWith(
      vehicleCost: vehicleCost,
      monthlySipAmount: sipAmount,
      tenureMonths: tenureMonths,
      monthlyIncome: income,
    ));
    _incomeCtrl.text = income.round().toString();
    _vehicleCostCtrl.text = vehicleCost.round().toString();
    _tenureCtrl.text = tenureMonths.toString();
    _sipAmountCtrl.text = sipAmount.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final timeline = plan.generateTimeline();
    final finalSnapshot = timeline.last;
    final totalOdInterestPaid = finalSnapshot.cumulativeOdInterest;
    final totalSipInvested = finalSnapshot.cumulativeSipInvested;
    final maturedSipWealth = finalSnapshot.sipValuation;
    final isPayoffAchieved = finalSnapshot.canPayoffOd;
    final surplus = maturedSipWealth - plan.vehicleCost;

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
          // Header
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
                      child: const Icon(Icons.tune, color: AppTheme.primaryEmerald, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Variables & Input Studio',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Type custom numbers or pick presets to dynamically compute results',
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
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: AppTheme.gold, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Live Calculator',
                      style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Quick Presets Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Presets:',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  label: '🛵 Electric Scooter (₹1.5L)',
                  isActive: plan.vehicleCost == 150000 && plan.monthlySipAmount == 2000,
                  onTap: () => _applyPreset(
                    vehicleCost: 150000,
                    sipAmount: 2000,
                    tenureMonths: 60,
                    income: 50000,
                  ),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  label: '🚗 City Car (₹6.0L)',
                  isActive: plan.vehicleCost == 600000,
                  onTap: () => _applyPreset(
                    vehicleCost: 600000,
                    sipAmount: 8000,
                    tenureMonths: 60,
                    income: 100000,
                  ),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  label: '🚙 Compact SUV (₹12L)',
                  isActive: plan.vehicleCost == 1200000,
                  onTap: () => _applyPreset(
                    vehicleCost: 1200000,
                    sipAmount: 16000,
                    tenureMonths: 60,
                    income: 180000,
                  ),
                ),
                const SizedBox(width: 8),
                _buildPresetButton(
                  label: '⚡ Luxury EV (₹25L)',
                  isActive: plan.vehicleCost == 2500000,
                  onTap: () => _applyPreset(
                    vehicleCost: 2500000,
                    sipAmount: 32000,
                    tenureMonths: 60,
                    income: 350000,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Variables Input Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 550;
              final itemWidth = isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // 1. Monthly Net Income
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '1. Monthly Net Income',
                      controller: _incomeCtrl,
                      prefixText: '₹ ',
                      suffixText: '',
                      helperText: 'For 40% Needs, 30% Invest, 30% Reserve',
                      icon: Icons.account_balance_wallet,
                      accentColor: AppTheme.electricCyan,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 5000,
                      onStep: (delta) {
                        final curr = double.tryParse(_incomeCtrl.text) ?? plan.monthlyIncome;
                        _incomeCtrl.text = (curr + delta).clamp(10000, 10000000).round().toString();
                        _applyChanges();
                      },
                    ),
                  ),

                  // 2. Expense of Scooter / Vehicle
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '2. Scooter / Vehicle Expense',
                      controller: _vehicleCostCtrl,
                      prefixText: '₹ ',
                      suffixText: '',
                      helperText: 'Total purchase on-road price',
                      icon: Icons.two_wheeler,
                      accentColor: AppTheme.gold,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 10000,
                      onStep: (delta) {
                        final curr = double.tryParse(_vehicleCostCtrl.text) ?? plan.vehicleCost;
                        _vehicleCostCtrl.text = (curr + delta).clamp(10000, 50000000).round().toString();
                        _applyChanges();
                      },
                    ),
                  ),

                  // 3. Overdraft (OD) Interest Rate
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '3. Gold OD Interest Rate',
                      controller: _odRateCtrl,
                      prefixText: '',
                      suffixText: ' % p.a.',
                      helperText: 'Bank interest charged on OD account',
                      icon: Icons.percent,
                      accentColor: AppTheme.gold,
                      isDecimal: true,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 0.5,
                      onStep: (delta) {
                        final curr = double.tryParse(_odRateCtrl.text) ?? plan.odInterestRateAnnual;
                        _odRateCtrl.text = (curr + delta).clamp(1.0, 30.0).toStringAsFixed(1);
                        _applyChanges();
                      },
                    ),
                  ),

                  // 4. Monthly SIP Amount
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '4. Monthly SIP Investment',
                      controller: _sipAmountCtrl,
                      prefixText: '₹ ',
                      suffixText: ' /mo',
                      helperText: 'Parallel wealth creation in mutual fund',
                      icon: Icons.trending_up,
                      accentColor: AppTheme.primaryEmerald,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 500,
                      onStep: (delta) {
                        final curr = double.tryParse(_sipAmountCtrl.text) ?? plan.monthlySipAmount;
                        _sipAmountCtrl.text = (curr + delta).clamp(500, 1000000).round().toString();
                        _applyChanges();
                      },
                    ),
                  ),

                  // 5. SIP Expected Return (CAGR)
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '5. Expected SIP CAGR',
                      controller: _sipCagrCtrl,
                      prefixText: '',
                      suffixText: ' % p.a.',
                      helperText: 'Historical equity long-term compounding',
                      icon: Icons.show_chart,
                      accentColor: AppTheme.primaryEmerald,
                      isDecimal: true,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 0.5,
                      onStep: (delta) {
                        final curr = double.tryParse(_sipCagrCtrl.text) ?? plan.sipReturnRateAnnual;
                        _sipCagrCtrl.text = (curr + delta).clamp(1.0, 35.0).toStringAsFixed(1);
                        _applyChanges();
                      },
                    ),
                  ),

                  // 6. Interest Paying Time / Duration
                  SizedBox(
                    width: itemWidth,
                    child: _buildInputCard(
                      label: '6. Paying Duration / Tenure',
                      controller: _tenureCtrl,
                      prefixText: '',
                      suffixText: ' Months',
                      helperText: 'Time to service OD interest and compound SIP',
                      icon: Icons.calendar_month,
                      accentColor: AppTheme.purpleAccent,
                      onChanged: (_) => _applyChanges(),
                      stepValue: 6,
                      onStep: (delta) {
                        final curr = int.tryParse(_tenureCtrl.text) ?? plan.tenureMonths;
                        _tenureCtrl.text = (curr + delta.round()).clamp(12, 120).toString();
                        _applyChanges();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Computed Numbers Statement List
          Container(
            padding: const EdgeInsets.all(16),
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
                          Icon(Icons.list_alt, color: AppTheme.primaryEmerald, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dynamic Statement & Calculated Numbers',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPayoffAchieved
                            ? AppTheme.primaryEmerald.withValues(alpha: 0.2)
                            : AppTheme.debtRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPayoffAchieved ? '100% FREE SUCCESS' : 'UNDERFUNDED',
                        style: TextStyle(
                          color: isPayoffAchieved ? AppTheme.primaryEmerald : AppTheme.debtRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Statement details list
                _buildStatementRow('1. 40% Necessities Budget:', CurrencyHelper.format(plan.necessitiesBudget)),
                _buildStatementRow('2. 30% Investments Budget:', CurrencyHelper.format(plan.investmentBudget)),
                _buildStatementRow('3. 30% Cash Reserve Budget:', CurrencyHelper.format(plan.cashReserveBudget)),
                _buildStatementRow('4. Safe Credit Limit (18 × 30%):', CurrencyHelper.format(plan.healthyCreditLimit), color: AppTheme.gold),
                const Divider(color: AppTheme.border, height: 16),
                _buildStatementRow('5. Monthly OD Interest Only:', '${CurrencyHelper.format(plan.monthlyOdInterest)} / month', color: AppTheme.gold),
                _buildStatementRow('6. Monthly SIP Investment:', '${CurrencyHelper.format(plan.monthlySipAmount)} / month', color: AppTheme.primaryEmerald),
                _buildStatementRow('7. Total Monthly Outflow (OD + SIP):', '${CurrencyHelper.format(plan.totalMonthlyOutflow)} / month', isBold: true),
                _buildStatementRow('8. Cumulative OD Interest Paid (${plan.tenureMonths} Mo):', CurrencyHelper.format(totalOdInterestPaid)),
                _buildStatementRow('9. Total SIP Capital Invested (${plan.tenureMonths} Mo):', CurrencyHelper.format(totalSipInvested)),
                _buildStatementRow('10. Matured SIP Valuation at Mo ${plan.tenureMonths}:', CurrencyHelper.format(maturedSipWealth), color: AppTheme.primaryEmerald, isBold: true),
                _buildStatementRow('11. OD Loan Principal to Wipe Out:', CurrencyHelper.format(plan.vehicleCost), color: AppTheme.electricCyan),
                _buildStatementRow(
                  '12. Net Surplus Cash After Debt Payoff:',
                  surplus >= 0 ? '+${CurrencyHelper.format(surplus)}' : '-${CurrencyHelper.format(surplus.abs())}',
                  color: surplus >= 0 ? AppTheme.primaryEmerald : AppTheme.debtRed,
                  isBold: true,
                ),
                _buildStatementRow('13. Estimated Free Payoff Month:', 'Month ${plan.payoffMonth}', color: AppTheme.electricCyan, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryEmerald : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryEmerald : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String prefixText,
    required String suffixText,
    required String helperText,
    required IconData icon,
    required Color accentColor,
    required ValueChanged<String> onChanged,
    required double stepValue,
    required ValueChanged<double> onStep,
    bool isDecimal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Decrement stepper
              InkWell(
                onTap: () => onStep(-stepValue),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 6),
              // Input field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      if (prefixText.isNotEmpty)
                        Text(
                          prefixText,
                          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*')),
                          ],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: onChanged,
                        ),
                      ),
                      if (suffixText.isNotEmpty)
                        Text(
                          suffixText,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Increment stepper
              InkWell(
                onTap: () => onStep(stepValue),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.add, size: 14, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            helperText,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatementRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
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
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
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
