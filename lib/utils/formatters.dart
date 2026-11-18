import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double value) {
    return _inrFormat.format(value.round());
  }

  static String formatCompact(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)} k';
    }
    return format(value);
  }

  static String formatMonth(int month) {
    if (month == 0) return 'Start (Day 1)';
    final years = month ~/ 12;
    final remainingMonths = month % 12;
    if (years > 0 && remainingMonths == 0) {
      return 'Year $years (Mo $month)';
    } else if (years > 0) {
      return 'Yr $years, Mo $remainingMonths';
    }
    return 'Month $month';
  }
}
