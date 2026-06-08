/// The product categories a warranty can belong to.
///
/// Stored in the database as the [label] string. Pure Dart — no Flutter/Drift.
library;

enum WarrantyCategory {
  electronics('Electronics'),
  homeAppliances('Home Appliances'),
  furniture('Furniture'),
  vehicle('Vehicle'),
  mobileDevices('Mobile Devices'),
  others('Others');

  const WarrantyCategory(this.label);

  /// Human-readable label, also the value persisted in the DB.
  final String label;

  /// Resolve a stored label back to an enum (defaults to [others]).
  static WarrantyCategory fromLabel(String? value) =>
      values.firstWhere((c) => c.label == value, orElse: () => others);
}
