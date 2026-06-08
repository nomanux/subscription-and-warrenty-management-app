/// Drift-backed implementation of [WarrantyRepository].
///
/// Maps DB rows ↔ domain entities, persists a warranty and its receipts in a
/// single transaction, cleans up orphaned receipt files, and keeps expiry
/// reminders in sync via [NotificationService].
library;

import 'package:drift/drift.dart';

import 'package:warranty_vault/core/constants/categories.dart';
import 'package:warranty_vault/core/database/app_database.dart';
import 'package:warranty_vault/core/notifications/notification_service.dart';
import 'package:warranty_vault/features/receipts/data/repositories/receipt_storage.dart';
import 'package:warranty_vault/features/receipts/domain/entities/receipt.dart';
import 'package:warranty_vault/features/warranties/domain/entities/warranty.dart';
import 'package:warranty_vault/features/warranties/domain/repositories/warranty_repository.dart';

class WarrantyRepositoryImpl implements WarrantyRepository {
  WarrantyRepositoryImpl(this._db, this._notifications, this._storage);

  final AppDatabase _db;
  final NotificationService _notifications;
  final ReceiptStorage _storage;

  // ---- mapping ----

  Warranty _toEntity(WarrantyRow row, List<ReceiptRow> receiptRows) {
    return Warranty(
      id: row.id,
      productName: row.productName,
      category: WarrantyCategory.fromLabel(row.category),
      purchaseDate: row.purchaseDate,
      warrantyMonths: row.warrantyMonths,
      expiryDate: row.expiryDate,
      storeName: row.storeName,
      notes: row.notes,
      receipts: receiptRows
          .map((r) => Receipt(
                id: r.id,
                warrantyId: r.warrantyId,
                filePath: r.filePath,
                createdAt: r.createdAt,
              ))
          .toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WarrantiesCompanion _toCompanion(Warranty w) => WarrantiesCompanion(
        id: Value(w.id),
        productName: Value(w.productName),
        category: Value(w.category.label),
        purchaseDate: Value(w.purchaseDate),
        warrantyMonths: Value(w.warrantyMonths),
        expiryDate: Value(w.expiryDate),
        storeName: Value(w.storeName),
        notes: Value(w.notes),
        createdAt: Value(w.createdAt),
        updatedAt: Value(w.updatedAt),
      );

  ReceiptsCompanion _receiptCompanion(String warrantyId, Receipt r) =>
      ReceiptsCompanion(
        id: Value(r.id),
        warrantyId: Value(warrantyId),
        filePath: Value(r.filePath),
        createdAt: Value(r.createdAt),
      );

  Future<List<ReceiptRow>> _receiptsFor(String warrantyId) =>
      (_db.select(_db.receipts)..where((r) => r.warrantyId.equals(warrantyId)))
          .get();

  // ---- queries ----

  @override
  Stream<List<Warranty>> watchAll() {
    final query = _db.select(_db.warranties)
      ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]);
    return query.watch().asyncMap((rows) async {
      final result = <Warranty>[];
      for (final row in rows) {
        result.add(_toEntity(row, await _receiptsFor(row.id)));
      }
      return result;
    });
  }

  @override
  Future<Warranty?> getById(String id) async {
    final row = await (_db.select(_db.warranties)
          ..where((w) => w.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toEntity(row, await _receiptsFor(id));
  }

  // ---- writes ----

  @override
  Future<void> add(Warranty warranty) async {
    await _db.transaction(() async {
      await _db.into(_db.warranties).insert(_toCompanion(warranty));
      for (final r in warranty.receipts) {
        await _db
            .into(_db.receipts)
            .insert(_receiptCompanion(warranty.id, r));
      }
    });
    await _reschedule(warranty);
  }

  @override
  Future<void> update(Warranty warranty) async {
    // Files no longer referenced after this update get deleted from disk.
    final existing = await _receiptsFor(warranty.id);
    final keepPaths = warranty.receipts.map((r) => r.filePath).toSet();
    final removed =
        existing.where((r) => !keepPaths.contains(r.filePath)).toList();

    await _db.transaction(() async {
      await (_db.update(_db.warranties)..where((t) => t.id.equals(warranty.id)))
          .write(_toCompanion(warranty));
      await (_db.delete(_db.receipts)
            ..where((r) => r.warrantyId.equals(warranty.id)))
          .go();
      for (final r in warranty.receipts) {
        await _db
            .into(_db.receipts)
            .insert(_receiptCompanion(warranty.id, r));
      }
    });

    for (final r in removed) {
      await _storage.deleteFile(r.filePath);
    }
    await _reschedule(warranty);
  }

  @override
  Future<void> delete(String id) async {
    final receipts = await _receiptsFor(id);
    await _notifications.cancelForWarranty(id);
    // Cascade removes receipt + scheduled_notification rows.
    await (_db.delete(_db.warranties)..where((w) => w.id.equals(id))).go();
    for (final r in receipts) {
      await _storage.deleteFile(r.filePath);
    }
  }

  Future<void> _reschedule(Warranty w) => _notifications.scheduleForWarranty(
        warrantyId: w.id,
        productName: w.productName,
        expiryDate: w.expiryDate,
      );
}
