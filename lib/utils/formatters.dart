import 'package:intl/intl.dart';

String formatKES(double amount) {
  final formatter = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String formatKESCompact(double amount) {
  if (amount >= 1000) {
    return 'KSh ${amount.toInt()}';
  }
  return 'KSh ${amount.toStringAsFixed(0)}';
}
