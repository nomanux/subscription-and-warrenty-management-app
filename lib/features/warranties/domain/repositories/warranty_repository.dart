/// Repository contract for warranties (domain layer — pure Dart).
///
/// The presentation layer depends only on this interface; the Drift-backed
/// implementation lives in the data layer.
library;

import 'package:warranty_vault/features/warranties/domain/entities/warranty.dart';

abstract interface class WarrantyRepository {
  /// Reactive stream of all warranties, newest first.
  Stream<List<Warranty>> watchAll();

  /// A single warranty (with its receipts), or null if missing.
  Future<Warranty?> getById(String id);

  /// Create a warranty (+ its receipts) and schedule its reminders.
  Future<void> add(Warranty warranty);

  /// Update a warranty (+ receipts) and reschedule its reminders.
  Future<void> update(Warranty warranty);

  /// Delete a warranty, its receipt files, and its reminders.
  Future<void> delete(String id);
}
