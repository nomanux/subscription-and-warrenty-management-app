/// Product service — Cloud Firestore implementation with local Drift sync.
///
/// Direct port of the React Native `productService.ts`. Data lives in the
/// `products` collection. Dates are stored as ISO strings (matching the
/// Product model), so no Timestamp mapping is needed. Status is recomputed on
/// read so it stays current.
///
/// All changes are synced to the local Drift database for offline access.
///
/// Note: there is no per-user scoping yet — every device shares the same
/// `products` collection, exactly like the old app.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../core/database/app_database.dart';
import '../models/product.dart';
import '../utils/warranty.dart';

class ProductService {
  ProductService({
    FirebaseFirestore? firestore,
    this._localDb,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  AppDatabase? _localDb;

  /// Set the local database for syncing (called after db initialization).
  void setLocalDatabase(AppDatabase db) {
    _localDb = db;
  }

  static const String _collection = 'products';

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(_collection);

  /// Recompute status from expiry so it reflects the current date.
  Product _withFreshStatus(Product product) =>
      product.copyWith(status: computeStatus(product.expiryDate));

  /// Live stream of all products, newest first. Status is refreshed per emit.
  Stream<List<Product>> watchProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => _withFreshStatus(Product.fromMap(d.id, d.data())))
            .toList());
  }

  /// All products, newest first (one-shot read).
  Future<List<Product>> getProducts() async {
    final snapshot =
        await _products.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((d) => _withFreshStatus(Product.fromMap(d.id, d.data())))
        .toList();
  }

  /// A single product by id, or null if not found.
  Future<Product?> getProduct(String id) async {
    final snapshot = await _products.doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return _withFreshStatus(Product.fromMap(snapshot.id, data));
  }

  /// Create a product; derives id, expiry, status, timestamps.
  Future<Product> createProduct(
    ProductInput input, {
    ProductSource source = ProductSource.manual,
  }) async {
    final ref = _products.doc();
    final now = DateTime.now().toUtc().toIso8601String();
    final expiryDate =
        calculateExpiryDate(input.purchaseDate, input.warrantyDurationMonths);

    final product = Product(
      id: ref.id,
      productName: input.productName,
      brand: input.brand,
      category: input.category,
      purchaseDate: input.purchaseDate,
      warrantyDurationMonths: input.warrantyDurationMonths,
      serialNumber: input.serialNumber,
      modelNumber: input.modelNumber,
      notes: input.notes,
      receipt: input.receipt,
      location: input.location,
      shopName: input.shopName,
      shopPhoneNumber: input.shopPhoneNumber,
      visitingCard: input.visitingCard,
      warrantyCard: input.warrantyCard,
      productImage: input.productImage,
      expiryDate: expiryDate,
      status: computeStatus(expiryDate),
      source: source,
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(product.toMap());
    await _syncToLocal(product);
    return product;
  }

  /// Update a product; recomputes expiry/status from merged values.
  Future<Product> updateProduct(String id, ProductInput input) async {
    final existing = await getProduct(id);
    if (existing == null) {
      throw StateError('Product "$id" not found');
    }

    final expiryDate =
        calculateExpiryDate(input.purchaseDate, input.warrantyDurationMonths);

    final updated = Product(
      id: id,
      productName: input.productName,
      brand: input.brand,
      category: input.category,
      purchaseDate: input.purchaseDate,
      warrantyDurationMonths: input.warrantyDurationMonths,
      serialNumber: input.serialNumber,
      modelNumber: input.modelNumber,
      notes: input.notes,
      receipt: input.receipt,
      location: input.location,
      shopName: input.shopName,
      shopPhoneNumber: input.shopPhoneNumber,
      visitingCard: input.visitingCard,
      warrantyCard: input.warrantyCard,
      productImage: input.productImage,
      expiryDate: expiryDate,
      status: computeStatus(expiryDate),
      source: existing.source,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    await _products.doc(id).set(updated.toMap());
    await _syncToLocal(updated);
    return updated;
  }

  /// Permanently remove a product.
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
    await _syncDeleteLocal(id);
  }

  /// Write a product under its existing id (create or overwrite).
  ///
  /// Used by Google Drive restore to merge a backup back into Firestore while
  /// preserving the original ids (so re-running a restore is idempotent).
  Future<void> upsertProduct(Product product) async {
    await _products.doc(product.id).set(product.toMap());
    await _syncToLocal(product);
  }

  /// Delete all products from Firestore (used for cleanup).
  Future<void> deleteAllProducts() async {
    final snapshot = await _products.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Sync product to local database.
  Future<void> _syncToLocal(Product product) async {
    final db = _localDb;
    if (db == null) return;
    try {
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
    } catch (_) {
      // Local sync failed - continue anyway (Firestore is source of truth)
    }
  }

  /// Delete product from local database.
  Future<void> _syncDeleteLocal(String id) async {
    final db = _localDb;
    if (db == null) return;
    try {
      await (db.delete(db.warranties)
            ..where((t) => t.id.equals(id)))
          .go();
    } catch (_) {
      // Local sync failed - continue anyway
    }
  }

}

/// Single shared instance, mirroring the old module-level service functions.
final productService = ProductService();
