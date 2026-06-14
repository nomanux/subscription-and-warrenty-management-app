/// Product service — Cloud Firestore implementation.
///
/// Direct port of the React Native `productService.ts`. Data lives in the
/// `products` collection. Dates are stored as ISO strings (matching the
/// Product model), so no Timestamp mapping is needed. Status is recomputed on
/// read so it stays current.
///
/// Note: there is no per-user scoping yet — every device shares the same
/// `products` collection, exactly like the old app.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../utils/warranty.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
      expiryDate: expiryDate,
      status: computeStatus(expiryDate),
      source: source,
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(product.toMap());
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
      expiryDate: expiryDate,
      status: computeStatus(expiryDate),
      source: existing.source,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    await _products.doc(id).set(updated.toMap());
    return updated;
  }

  /// Permanently remove a product.
  Future<void> deleteProduct(String id) => _products.doc(id).delete();

  /// Write a product under its existing id (create or overwrite).
  ///
  /// Used by Google Drive restore to merge a backup back into Firestore while
  /// preserving the original ids (so re-running a restore is idempotent).
  Future<void> upsertProduct(Product product) =>
      _products.doc(product.id).set(product.toMap());

  /// Seed demo data if collection is empty.
  Future<void> seedDemoDataIfEmpty() async {
    final existing = await _products.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final demoProducts = _getDemoProducts();
    for (final product in demoProducts) {
      await _products.doc(product.id).set(product.toMap());
    }
  }

  List<Product> _getDemoProducts() {
    const demoImages = {
      'Instant Hotpot': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
      'MacBook Pro 14"':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12P4z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==',
      'iPhone 15':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12NgYGBgAAAABAABSK+kcQAAAABJRU5ErkJggg==',
      'Anker PowerBank':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP4//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==',
      'Ceiling Fan':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      'Office Chair':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      'Toyota Corolla':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==',
      'Electric Kettle':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==',
      'Wrist Watch':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      'Headphones':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
      'Blender':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      'Motorcycle':
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
    };

    const seedItems = [
      ('seed-001', 'Instant Hotpot', 'Home Appliances', '2025-09-01', 24,
          'Daraz'),
      ('seed-002', 'MacBook Pro 14"', 'Electronics', '2025-12-10', 12,
          'Apple Store'),
      ('seed-003', 'iPhone 15', 'Electronics', '2026-01-05', 24,
          'Apple Store'),
      ('seed-004', 'Anker PowerBank', 'Electronics', '2026-03-15', 18,
          'Amazon'),
      ('seed-005', 'Ceiling Fan', 'Home Appliances', '2025-11-20', 36,
          'Singer'),
      ('seed-006', 'Office Chair', 'Furniture', '2026-01-20', 24, 'IKEA'),
      ('seed-007', 'Toyota Corolla', 'Vehicle', '2025-08-15', 36, 'Toyota'),
      ('seed-008', 'Electric Kettle', 'Home Appliances', '2025-06-20', 12,
          'Philips'),
      ('seed-009', 'Wrist Watch', 'Others', '2024-06-25', 24, 'Casio'),
      ('seed-010', 'Headphones', 'Electronics', '2024-07-02', 24,
          'Sony Center'),
      ('seed-011', 'Blender', 'Home Appliances', '2023-01-10', 12,
          'Nutribullet'),
      ('seed-012', 'Motorcycle', 'Vehicle', '2021-03-01', 36, 'Honda'),
    ];

    final now = DateTime.now().toUtc().toIso8601String();
    final products = <Product>[];

    for (final (id, name, category, purchase, months, _) in seedItems) {
      final expiryDate = calculateExpiryDate(purchase, months);
      final imageUri = demoImages[name] ?? demoImages['Instant Hotpot']!;

      products.add(
        Product(
          id: id,
          productName: name,
          brand: null,
          category: category,
          purchaseDate: purchase,
          warrantyDurationMonths: months,
          serialNumber: null,
          modelNumber: null,
          notes: null,
          receipt: ReceiptFile(uri: imageUri),
          expiryDate: expiryDate,
          status: computeStatus(expiryDate),
          source: ProductSource.manual,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return products;
  }
}

/// Single shared instance, mirroring the old module-level service functions.
final productService = ProductService();
