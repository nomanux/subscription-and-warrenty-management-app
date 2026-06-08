/// The core domain entity — a single warranty record.
///
/// Pure Dart: no Drift, no Flutter. Status and days-remaining are derived from
/// [expiryDate] at read time so they never go stale.
library;

import 'package:warranty_vault/core/constants/categories.dart';
import 'package:warranty_vault/features/receipts/domain/entities/receipt.dart';
import 'package:warranty_vault/features/warranties/domain/entities/warranty_status.dart';

class Warranty {
  const Warranty({
    required this.id,
    required this.productName,
    required this.category,
    required this.purchaseDate,
    required this.warrantyMonths,
    required this.expiryDate,
    this.storeName,
    this.notes,
    this.receipts = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String productName;
  final WarrantyCategory category;
  final DateTime purchaseDate;
  final int warrantyMonths;
  final DateTime expiryDate;
  final String? storeName;
  final String? notes;
  final List<Receipt> receipts;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// A warranty within this many days of expiry counts as "expiring soon".
  static const int expiringSoonThresholdDays = 30;

  /// Whole calendar days until expiry (negative if already expired).
  int daysRemaining([DateTime? now]) {
    final ref = now ?? DateTime.now();
    final a = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final b = DateTime(ref.year, ref.month, ref.day);
    return a.difference(b).inDays;
  }

  /// Derived status from the expiry date.
  WarrantyStatus status([DateTime? now]) {
    final days = daysRemaining(now);
    if (days < 0) return WarrantyStatus.expired;
    if (days <= expiringSoonThresholdDays) return WarrantyStatus.expiring;
    return WarrantyStatus.active;
  }

  Warranty copyWith({
    String? productName,
    WarrantyCategory? category,
    DateTime? purchaseDate,
    int? warrantyMonths,
    DateTime? expiryDate,
    String? storeName,
    String? notes,
    List<Receipt>? receipts,
    DateTime? updatedAt,
  }) {
    return Warranty(
      id: id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      expiryDate: expiryDate ?? this.expiryDate,
      storeName: storeName ?? this.storeName,
      notes: notes ?? this.notes,
      receipts: receipts ?? this.receipts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
