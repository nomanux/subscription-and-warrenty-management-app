/// One-time database seeder for demo/preview data.
///
/// Writes 20 sample products to the `products` collection using deterministic
/// IDs (`seed-001`..`seed-020`) so re-running overwrites instead of duplicating.
/// Purchase dates + warranty months are chosen to produce a mix of active /
/// expiring / expired so the dashboard stats look realistic.
///
/// This is dev-only: call it once from main(), then remove the call.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../utils/warranty.dart';

class _Seed {
  const _Seed(this.name, this.brand, this.category, this.purchase, this.months);
  final String name;
  final String brand;
  final String category;
  final String purchase; // YYYY-MM-DD
  final int months;
}

// status target relative to ~2026-06: pick purchase+months accordingly.
const List<_Seed> _items = [
  // ---- active (expiry comfortably in the future) ----
  _Seed('Instant Hotpot', 'Xiaomi', 'Kitchen Appliances', '2025-09-01', 24),
  _Seed('MacBook Pro 14"', 'Apple', 'Electronics', '2025-12-10', 12),
  _Seed('iPhone 15', 'Apple', 'Electronics', '2026-01-05', 24),
  _Seed('Anker PowerBank', 'Anker', 'Electronics', '2026-03-15', 18),
  _Seed('Ceiling Fan', 'Orient', 'Home Appliances', '2025-11-20', 36),
  _Seed('Smart TV 55"', 'Samsung', 'Electronics', '2025-10-01', 24),
  _Seed('Washing Machine', 'LG', 'Home Appliances', '2026-02-01', 24),
  _Seed('Air Conditioner', 'Daikin', 'Home Appliances', '2025-08-15', 36),
  _Seed('Gaming Monitor', 'Dell', 'Electronics', '2026-04-01', 12),
  _Seed('Office Chair', 'IKEA', 'Furniture', '2026-01-20', 24),
  _Seed('Microwave Oven', 'Panasonic', 'Kitchen Appliances', '2025-12-01', 18),
  _Seed('Bluetooth Speaker', 'JBL', 'Electronics', '2026-05-01', 12),
  // ---- expiring soon (expiry within ~30 days of 2026-06-08) ----
  _Seed('Electric Kettle', 'Philips', 'Kitchen Appliances', '2025-06-20', 12),
  _Seed('Wrist Watch', 'Casio', 'Others', '2024-06-25', 24),
  _Seed('Table Fan', 'Usha', 'Home Appliances', '2025-06-30', 12),
  _Seed('Headphones', 'Sony', 'Electronics', '2024-07-02', 24),
  // ---- expired (expiry already passed) ----
  _Seed('Blender', 'Nutribullet', 'Kitchen Appliances', '2023-01-10', 12),
  _Seed('Vacuum Cleaner', 'Dyson', 'Home Appliances', '2022-05-01', 24),
  _Seed('Motorcycle', 'Honda', 'Vehicle', '2021-03-01', 36),
  _Seed('Dining Table', 'Urban Ladder', 'Furniture', '2023-02-15', 12),
];

Future<void> seedProducts() async {
  final col = FirebaseFirestore.instance.collection('products');
  final now = DateTime.now().toUtc().toIso8601String();

  for (var i = 0; i < _items.length; i++) {
    final it = _items[i];
    final id = 'seed-${(i + 1).toString().padLeft(3, '0')}';
    final purchaseIso = DateTime.parse(it.purchase).toUtc().toIso8601String();
    final expiry = calculateExpiryDate(purchaseIso, it.months);

    final product = Product(
      id: id,
      productName: it.name,
      brand: it.brand,
      category: it.category,
      purchaseDate: purchaseIso,
      warrantyDurationMonths: it.months,
      serialNumber: null,
      modelNumber: null,
      notes: null,
      receipt: null,
      expiryDate: expiry,
      status: computeStatus(expiry),
      source: ProductSource.manual,
      createdAt: now,
      updatedAt: now,
    );

    await col.doc(id).set(product.toMap());
  }
}
