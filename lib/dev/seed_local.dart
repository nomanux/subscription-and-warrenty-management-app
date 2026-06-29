/// Syncs Firestore data to local Drift database on startup.
library;

import 'package:drift/drift.dart';
import 'package:warranty_vault/core/database/app_database.dart';
import 'package:warranty_vault/services/product_service.dart';

Future<void> seedLocalIfEmpty(AppDatabase db) async {
  try {
    // Check if local database is empty
    final count = await db.select(db.warranties).get();
    if (count.isNotEmpty) {
      // Local database already has data, skip sync
      return;
    }

    // Local database is empty, sync from Firestore
    final products = await productService.getProducts();

    for (final product in products) {
      await db.into(db.warranties).insert(
        WarrantiesCompanion(
          id: Value(product.id),
          productName: Value(product.productName),
          category: Value(product.category),
          purchaseDate: Value(DateTime.parse(product.purchaseDate)),
          warrantyMonths: Value(product.warrantyDurationMonths),
          expiryDate: Value(DateTime.parse(product.expiryDate)),
          storeName: Value(product.shopName),
          notes: Value(product.notes),
          createdAt: Value(DateTime.parse(product.createdAt)),
          updatedAt: Value(DateTime.parse(product.updatedAt)),
        ),
        onConflict: DoUpdate(
          (old) => WarrantiesCompanion(
            productName: Value(product.productName),
            category: Value(product.category),
            purchaseDate: Value(DateTime.parse(product.purchaseDate)),
            warrantyMonths: Value(product.warrantyDurationMonths),
            expiryDate: Value(DateTime.parse(product.expiryDate)),
            storeName: Value(product.shopName),
            notes: Value(product.notes),
            updatedAt: Value(DateTime.parse(product.updatedAt)),
          ),
        ),
      );
    }
  } catch (e) {
    // Sync failed - continue with whatever is in local database
    // (Could be empty if Firestore is unavailable)
    return;
  }
}
