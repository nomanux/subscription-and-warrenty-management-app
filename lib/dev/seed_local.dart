/// Seeds the local Drift database with demo warranties on first launch
/// (only if the table is empty). Categories match WarrantyCategory labels.
library;

import 'package:drift/drift.dart';

import 'package:warranty_vault/core/database/app_database.dart';
import 'package:warranty_vault/core/utils/warranty_dates.dart';

class _Seed {
  const _Seed(this.name, this.category, this.purchase, this.months, this.store);
  final String name;
  final String category;
  final String purchase; // YYYY-MM-DD
  final int months;
  final String store;
}

const _items = <_Seed>[
  // active
  _Seed('Instant Hotpot', 'Home Appliances', '2025-09-01', 24, 'Daraz'),
  _Seed('MacBook Pro 14"', 'Electronics', '2025-12-10', 12, 'Apple Store'),
  _Seed('iPhone 15', 'Mobile Devices', '2026-01-05', 24, 'Apple Store'),
  _Seed('Anker PowerBank', 'Electronics', '2026-03-15', 18, 'Amazon'),
  _Seed('Ceiling Fan', 'Home Appliances', '2025-11-20', 36, 'Singer'),
  _Seed('Office Chair', 'Furniture', '2026-01-20', 24, 'IKEA'),
  _Seed('Toyota Corolla', 'Vehicle', '2025-08-15', 36, 'Toyota'),
  // expiring soon
  _Seed('Electric Kettle', 'Home Appliances', '2025-06-20', 12, 'Philips'),
  _Seed('Wrist Watch', 'Others', '2024-06-25', 24, 'Casio'),
  _Seed('Headphones', 'Electronics', '2024-07-02', 24, 'Sony Center'),
  // expired
  _Seed('Blender', 'Home Appliances', '2023-01-10', 12, 'Nutribullet'),
  _Seed('Motorcycle', 'Vehicle', '2021-03-01', 36, 'Honda'),
];

Future<void> seedLocalIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.warranties).get();
  if (existing.isNotEmpty) return;

  final now = DateTime.now();
  await db.transaction(() async {
    for (var i = 0; i < _items.length; i++) {
      final it = _items[i];
      final purchase = DateTime.parse(it.purchase);
      await db.into(db.warranties).insert(
            WarrantiesCompanion.insert(
              id: 'seed-${(i + 1).toString().padLeft(3, '0')}',
              productName: it.name,
              category: it.category,
              purchaseDate: purchase,
              warrantyMonths: it.months,
              expiryDate: computeExpiry(purchase, it.months),
              storeName: Value(it.store),
              notes: const Value.absent(),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  });
}
