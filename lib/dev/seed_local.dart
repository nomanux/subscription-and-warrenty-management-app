/// Seeds the local Drift database with demo warranties on first launch
/// (only if the table is empty). Includes dummy product images as data URIs.
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:warranty_vault/core/database/app_database.dart';
import 'package:warranty_vault/core/utils/warranty_dates.dart';

class _Seed {
  const _Seed({
    required this.name,
    required this.category,
    required this.purchase,
    required this.months,
    required this.store,
    required this.imageData,
  });

  final String name;
  final String category;
  final String purchase;
  final int months;
  final String store;
  final String imageData; // base64 PNG data
}

/// Colored PNG pixels as base64 (100x100 placeholder images)
const String _redPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';
const String _bluePx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12P4z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==';
const String _greenPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
const String _purplePx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
const String _orangePx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==';
const String _yellowPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP4//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==';
const String _blackPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12NgYGBgAAAABAABSK+kcQAAAABJRU5ErkJggg==';
const String _whitePx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==';
const String _grayPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
const String _brownPx =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

const _items = <_Seed>[
  // active
  _Seed(
    name: 'Instant Hotpot',
    category: 'Home Appliances',
    purchase: '2025-09-01',
    months: 24,
    store: 'Daraz',
    imageData: _redPx,
  ),
  _Seed(
    name: 'MacBook Pro 14"',
    category: 'Electronics',
    purchase: '2025-12-10',
    months: 12,
    store: 'Apple Store',
    imageData: _bluePx,
  ),
  _Seed(
    name: 'iPhone 15',
    category: 'Electronics',
    purchase: '2026-01-05',
    months: 24,
    store: 'Apple Store',
    imageData: _blackPx,
  ),
  _Seed(
    name: 'Anker PowerBank',
    category: 'Electronics',
    purchase: '2026-03-15',
    months: 18,
    store: 'Amazon',
    imageData: _yellowPx,
  ),
  _Seed(
    name: 'Ceiling Fan',
    category: 'Home Appliances',
    purchase: '2025-11-20',
    months: 36,
    store: 'Singer',
    imageData: _grayPx,
  ),
  _Seed(
    name: 'Office Chair',
    category: 'Furniture',
    purchase: '2026-01-20',
    months: 24,
    store: 'IKEA',
    imageData: _brownPx,
  ),
  _Seed(
    name: 'Toyota Corolla',
    category: 'Vehicle',
    purchase: '2025-08-15',
    months: 36,
    store: 'Toyota',
    imageData: _whitePx,
  ),
  // expiring soon
  _Seed(
    name: 'Electric Kettle',
    category: 'Home Appliances',
    purchase: '2025-06-20',
    months: 12,
    store: 'Philips',
    imageData: _orangePx,
  ),
  _Seed(
    name: 'Wrist Watch',
    category: 'Others',
    purchase: '2024-06-25',
    months: 24,
    store: 'Casio',
    imageData: _purplePx,
  ),
  _Seed(
    name: 'Headphones',
    category: 'Electronics',
    purchase: '2024-07-02',
    months: 24,
    store: 'Sony Center',
    imageData: _redPx,
  ),
  // expired
  _Seed(
    name: 'Blender',
    category: 'Home Appliances',
    purchase: '2023-01-10',
    months: 12,
    store: 'Nutribullet',
    imageData: _greenPx,
  ),
  _Seed(
    name: 'Motorcycle',
    category: 'Vehicle',
    purchase: '2021-03-01',
    months: 36,
    store: 'Honda',
    imageData: _redPx,
  ),
];

Future<void> seedLocalIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.warranties).get();
  if (existing.isNotEmpty) return;

  final now = DateTime.now();
  const uuid = Uuid();

  await db.transaction(() async {
    for (var i = 0; i < _items.length; i++) {
      final it = _items[i];
      final purchase = DateTime.parse(it.purchase);
      final warrantyId = 'seed-${(i + 1).toString().padLeft(3, '0')}';
      final imageUri = 'data:image/png;base64,${it.imageData}';

      // Insert warranty
      await db.into(db.warranties).insert(
            WarrantiesCompanion.insert(
              id: warrantyId,
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

      // Insert receipt with data URI
      await db.into(db.receipts).insert(
            ReceiptsCompanion.insert(
              id: uuid.v4(),
              warrantyId: warrantyId,
              filePath: imageUri,
              createdAt: now,
            ),
          );
    }
  });
}
