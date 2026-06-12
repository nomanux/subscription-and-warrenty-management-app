/// Warranty date math — pure functions, no storage/UI.
///
/// Direct port of the React Native `utils.ts`. Dates are passed/returned as
/// ISO strings to match how they are persisted in Firestore.
library;

import '../models/product.dart';

/// A warranty within this many days of expiry counts as "expiring soon".
const int kExpiringSoonThresholdDays = 30;

/// Normalize a date to local midnight so day math ignores the time-of-day.
DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Add whole months to a date, clamping the day if the target month is shorter
/// (e.g. Jan 31 + 1 month -> Feb 28, not Mar 3).
DateTime _addMonths(DateTime date, int months) {
  final targetDay = date.day;
  // Move to the first of the target month, then clamp the day.
  final base = DateTime(date.year, date.month + months, 1);
  final lastDayOfTargetMonth = DateTime(base.year, base.month + 1, 0).day;
  final day = targetDay < lastDayOfTargetMonth ? targetDay : lastDayOfTargetMonth;
  return DateTime(base.year, base.month, day);
}

/// Compute the warranty expiry date.
///
/// [purchaseDate] is an ISO date string; returns an ISO date string of expiry.
String calculateExpiryDate(String purchaseDate, int months) {
  final expiry = _addMonths(DateTime.parse(purchaseDate), months);
  return expiry.toUtc().toIso8601String();
}

/// Whole days remaining until expiry (based on calendar days).
/// Returns a negative number if the warranty has already expired.
int daysRemaining(String expiryDate, [DateTime? now]) {
  final reference = now ?? DateTime.now();
  final diff = _startOfDay(DateTime.parse(expiryDate))
      .difference(_startOfDay(reference));
  return diff.inDays;
}

/// Derive the warranty status from its expiry date.
///  - expired:  past the expiry date
///  - expiring: within [kExpiringSoonThresholdDays]
///  - active:   more time than that remaining
WarrantyStatus computeStatus(String expiryDate, [DateTime? now]) {
  final days = daysRemaining(expiryDate, now);
  if (days < 0) return WarrantyStatus.expired;
  if (days <= kExpiringSoonThresholdDays) return WarrantyStatus.expiring;
  return WarrantyStatus.active;
}

/// Format warranty duration for badge display.
/// Within 30 days: "X days", beyond 30 days: "2m", "2m 1d", "3m", etc.
String formatWarrantyDuration(int days) {
  if (days < 0) return 'Expired';
  if (days <= 30) return '$days day${days == 1 ? '' : 's'}';

  final months = days ~/ 30;
  final remainingDays = days % 30;

  if (remainingDays == 0) {
    return '${months}m';
  }
  return '${months}m ${remainingDays}d';
}
