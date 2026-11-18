import 'dart:math' as math;

class MonthSnapshot {
  final int month;
  final double cumulativeSipInvested;
  final double sipValuation;
  final double monthlyOdInterest;
  final double cumulativeOdInterest;
  final double odPrincipal;
  final double pledgedGoldValue;
  final double traditionalEmi;
  final double traditionalCumulativePaid;
  final double traditionalBalance;

  MonthSnapshot({
    required this.month,
    required this.cumulativeSipInvested,
    required this.sipValuation,
    required this.monthlyOdInterest,
    required this.cumulativeOdInterest,
    required this.odPrincipal,
    required this.pledgedGoldValue,
    required this.traditionalEmi,
    required this.traditionalCumulativePaid,
    required this.traditionalBalance,
  });

  bool get canPayoffOd => sipValuation >= odPrincipal;
  double get netWealthSurplus => sipValuation - odPrincipal;
  double get totalOdStrategyCostSoFar => cumulativeOdInterest + cumulativeSipInvested;
}

class FinancialPlan {
  // 40/30/30 Rule Inputs
  final double monthlyIncome;

  // Strategy Specifics
  final double vehicleCost;
  final double odInterestRateAnnual; // e.g., 8.0%
  final double monthlySipAmount; // e.g., 2000
  final double sipReturnRateAnnual; // e.g., 14.0%
  final double goldAppreciationAnnual; // e.g., 9.0%
  final double goldLtvRatio; // Loan to value (e.g. 75% -> 0.75)
  final int tenureMonths; // default 60

  // Traditional Loan Benchmark
  final double traditionalInterestRateAnnual; // e.g. 10.5%

  FinancialPlan({
    this.monthlyIncome = 50000,
    this.vehicleCost = 150000,
    this.odInterestRateAnnual = 8.0,
    this.monthlySipAmount = 2000,
    this.sipReturnRateAnnual = 14.0,
    this.goldAppreciationAnnual = 9.0,
    this.goldLtvRatio = 0.75,
    this.tenureMonths = 60,
    this.traditionalInterestRateAnnual = 10.5,
  });

  // 40/30/30 Allocation
  double get necessitiesBudget => monthlyIncome * 0.40;
  double get investmentBudget => monthlyIncome * 0.30;
  double get cashReserveBudget => monthlyIncome * 0.30;

  // Healthy Credit Limit (18x of 30% bucket)
  double get healthyCreditLimit => 18 * investmentBudget;

  // Gold required to pledge (Vehicle Cost / LTV)
  double get initialGoldValueRequired => vehicleCost / goldLtvRatio;

  // Monthly OD Interest (Only interest paid, principal stays intact until SIP payoff)
  double get monthlyOdInterest => (vehicleCost * (odInterestRateAnnual / 100)) / 12;

  // Total monthly commitment for strategy
  double get totalMonthlyOutflow => monthlyOdInterest + monthlySipAmount;

  // Percentage of 30% investment budget used by strategy
  double get investmentBudgetUtilizationPct =>
      investmentBudget > 0 ? (totalMonthlyOutflow / investmentBudget) * 100 : 0;

  // Traditional Loan EMI calculation
  double get traditionalMonthlyEmi {
    final r = (traditionalInterestRateAnnual / 100) / 12;
    final n = tenureMonths;
    if (r == 0) return vehicleCost / n;
    return (vehicleCost * r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
  }

  double get traditionalTotalPaid => traditionalMonthlyEmi * tenureMonths;
  double get traditionalTotalInterest => traditionalTotalPaid - vehicleCost;

  // Monthly Timeline Projection from 0 to tenureMonths
  List<MonthSnapshot> generateTimeline() {
    final snapshots = <MonthSnapshot>[];
    final monthlySipRate = (sipReturnRateAnnual / 100) / 12;
    final monthlyGoldRate = (goldAppreciationAnnual / 100) / 12;
    final tradRate = (traditionalInterestRateAnnual / 100) / 12;
    final tradEmi = traditionalMonthlyEmi;

    double runningTradBalance = vehicleCost;
    double runningTradPaid = 0;
    double currentSipValuation = 0;

    for (int m = 0; m <= tenureMonths; m++) {
      if (m == 0) {
        snapshots.add(MonthSnapshot(
          month: 0,
          cumulativeSipInvested: 0,
          sipValuation: 0,
          monthlyOdInterest: monthlyOdInterest,
          cumulativeOdInterest: 0,
          odPrincipal: vehicleCost,
          pledgedGoldValue: initialGoldValueRequired,
          traditionalEmi: tradEmi,
          traditionalCumulativePaid: 0,
          traditionalBalance: vehicleCost,
        ));
        continue;
      }

      // SIP growth: compounding previous value + new installment
      currentSipValuation = (currentSipValuation + monthlySipAmount) * (1 + monthlySipRate);
      final cumulativeInvested = monthlySipAmount * m;
      final cumulativeOdInterest = monthlyOdInterest * m;
      final currentGoldVal = initialGoldValueRequired * math.pow(1 + monthlyGoldRate, m);

      // Traditional loan amortization
      final interestThisMonth = runningTradBalance * tradRate;
      final principalThisMonth = tradEmi - interestThisMonth;
      runningTradBalance = math.max(0, runningTradBalance - principalThisMonth);
      runningTradPaid += tradEmi;

      snapshots.add(MonthSnapshot(
        month: m,
        cumulativeSipInvested: cumulativeInvested,
        sipValuation: currentSipValuation,
        monthlyOdInterest: monthlyOdInterest,
        cumulativeOdInterest: cumulativeOdInterest,
        odPrincipal: vehicleCost,
        pledgedGoldValue: currentGoldVal,
        traditionalEmi: tradEmi,
        traditionalCumulativePaid: runningTradPaid,
        traditionalBalance: runningTradBalance,
      ));
    }
    return snapshots;
  }

  // Find exact month when SIP overtakes OD Principal
  int get payoffMonth {
    final timeline = generateTimeline();
    for (final s in timeline) {
      if (s.canPayoffOd) return s.month;
    }
    return tenureMonths;
  }

  FinancialPlan copyWith({
    double? monthlyIncome,
    double? vehicleCost,
    double? odInterestRateAnnual,
    double? monthlySipAmount,
    double? sipReturnRateAnnual,
    double? goldAppreciationAnnual,
    double? goldLtvRatio,
    int? tenureMonths,
    double? traditionalInterestRateAnnual,
  }) {
    return FinancialPlan(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      vehicleCost: vehicleCost ?? this.vehicleCost,
      odInterestRateAnnual: odInterestRateAnnual ?? this.odInterestRateAnnual,
      monthlySipAmount: monthlySipAmount ?? this.monthlySipAmount,
      sipReturnRateAnnual: sipReturnRateAnnual ?? this.sipReturnRateAnnual,
      goldAppreciationAnnual: goldAppreciationAnnual ?? this.goldAppreciationAnnual,
      goldLtvRatio: goldLtvRatio ?? this.goldLtvRatio,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      traditionalInterestRateAnnual:
          traditionalInterestRateAnnual ?? this.traditionalInterestRateAnnual,
    );
  }
}
