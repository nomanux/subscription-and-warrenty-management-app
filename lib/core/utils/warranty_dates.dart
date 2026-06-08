/// Warranty date math — pure functions, no storage/UI.
library;

/// Add whole months to a date, clamping the day when the target month is
/// shorter (e.g. Jan 31 + 1 month → Feb 28).
DateTime addMonths(DateTime date, int months) {
  final targetDay = date.day;
  final base = DateTime(date.year, date.month + months, 1);
  final lastDayOfTargetMonth = DateTime(base.year, base.month + 1, 0).day;
  final day = targetDay < lastDayOfTargetMonth ? targetDay : lastDayOfTargetMonth;
  return DateTime(base.year, base.month, day);
}

/// Expiry date = purchase date + warranty months.
DateTime computeExpiry(DateTime purchaseDate, int warrantyMonths) =>
    addMonths(purchaseDate, warrantyMonths);
