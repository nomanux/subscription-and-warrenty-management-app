/// Product feature types — the core data model of Warranty Vault.
///
/// This is a direct port of the React Native `types.ts`. The Firestore field
/// shape is kept identical (ISO date strings, same keys) so product documents
/// created by the old app load here without migration.
library;

import 'package:hugeicons/hugeicons.dart';

/// The six product categories, in display order.
const List<String> kCategories = [
  'Electronics',
  'Home Appliances',
  'Kitchen Appliances',
  'Furniture',
  'Vehicle',
  'Others',
];

/// Icon mapping for each category.
final Map<String, List<List<dynamic>>> kCategoryIcons = {
  'Electronics': HugeIcons.strokeRoundedSmartPhone01,
  'Home Appliances': HugeIcons.strokeRoundedHome01,
  'Kitchen Appliances': HugeIcons.strokeRoundedKitchenUtensils,
  'Furniture': HugeIcons.strokeRoundedChair01,
  'Vehicle': HugeIcons.strokeRoundedCar01,
  'Others': HugeIcons.strokeRoundedPackage01,
};

/// Warranty lifecycle status, derived from the expiry date.
enum WarrantyStatus {
  active,
  expiring,
  expired;

  /// The string stored in Firestore (matches the old app: "active" etc.).
  String get wire => name;

  static WarrantyStatus fromWire(String? value) {
    return WarrantyStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => WarrantyStatus.active,
    );
  }
}

/// How a product record was created.
enum ProductSource {
  manual,
  ai;

  String get wire => name;

  static ProductSource fromWire(String? value) {
    return ProductSource.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ProductSource.manual,
    );
  }
}

/// A single warranty coverage.
class WarrantyCoverage {
  const WarrantyCoverage({
    required this.id,
    required this.type,
    required this.duration,
    required this.durationUnit,
    required this.startDate,
    this.expiryDate,
  });

  final String id;
  final String type;
  final int duration;
  final String durationUnit;
  final String startDate;
  final String? expiryDate;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'duration': duration,
        'durationUnit': durationUnit,
        'startDate': startDate,
        'expiryDate': expiryDate,
      };

  static WarrantyCoverage? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return WarrantyCoverage(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? 'Manufacturer Warranty',
      duration: (map['duration'] as num?)?.toInt() ?? 1,
      durationUnit: map['durationUnit'] as String? ?? 'years',
      startDate: map['startDate'] as String? ?? '',
      expiryDate: map['expiryDate'] as String?,
    );
  }

  WarrantyCoverage copyWith({
    String? id,
    String? type,
    int? duration,
    String? durationUnit,
    String? startDate,
    String? expiryDate,
  }) {
    return WarrantyCoverage(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      durationUnit: durationUnit ?? this.durationUnit,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

/// A receipt attached to a product.
///
/// [uri] is local-only: a file path on the device, or a data/blob URI on web.
class ReceiptFile {
  const ReceiptFile({
    required this.uri,
    this.fileType = 'image',
    this.thumbnailUri,
  });

  final String uri;
  final String fileType; // 'image' | 'pdf'
  final String? thumbnailUri;

  Map<String, dynamic> toMap() => {
        'uri': uri,
        'fileType': fileType,
        if (thumbnailUri != null) 'thumbnailUri': thumbnailUri,
      };

  static ReceiptFile? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return ReceiptFile(
      uri: map['uri'] as String? ?? '',
      fileType: map['fileType'] as String? ?? 'image',
      thumbnailUri: map['thumbnailUri'] as String?,
    );
  }
}

/// Fields the user actually supplies in the Add/Edit form.
///
/// Computed fields (expiryDate, status) and lifecycle fields (id, timestamps)
/// are NOT here — the service derives/assigns them.
class ProductInput {
  const ProductInput({
    required this.productName,
    this.brand,
    required this.category,
    required this.purchaseDate,
    required this.warrantyDurationMonths,
    this.serialNumber,
    this.modelNumber,
    this.notes,
    this.receipt,
    this.location,
    this.shopName,
    this.shopPhoneNumber,
    this.visitingCard,
    this.warrantyCard,
    this.productImage,
    this.coverages = const [],
  });

  final String productName;
  final String? brand;
  final String category;

  /// ISO date string of purchase.
  final String purchaseDate;
  final int warrantyDurationMonths;
  final String? serialNumber;
  final String? modelNumber;
  final String? notes;
  final ReceiptFile? receipt;
  final String? location;
  final String? shopName;
  final String? shopPhoneNumber;
  final ReceiptFile? visitingCard;
  final ReceiptFile? warrantyCard;
  final ReceiptFile? productImage;
  final List<WarrantyCoverage> coverages;
}

/// A full product record as stored in Firestore.
class Product {
  const Product({
    required this.id,
    required this.productName,
    this.brand,
    required this.category,
    required this.purchaseDate,
    required this.warrantyDurationMonths,
    this.serialNumber,
    this.modelNumber,
    this.notes,
    this.receipt,
    required this.expiryDate,
    required this.status,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.shopName,
    this.shopPhoneNumber,
    this.visitingCard,
    this.warrantyCard,
    this.productImage,
    this.coverages = const [],
  });

  final String id;
  final String productName;
  final String? brand;
  final String category;
  final String purchaseDate;
  final int warrantyDurationMonths;
  final String? serialNumber;
  final String? modelNumber;
  final String? notes;
  final ReceiptFile? receipt;

  /// ISO date string, computed = purchaseDate + warrantyDurationMonths.
  final String expiryDate;
  final WarrantyStatus status;
  final ProductSource source;
  final String createdAt;
  final String updatedAt;
  final String? location;
  final String? shopName;
  final String? shopPhoneNumber;
  final ReceiptFile? visitingCard;
  final ReceiptFile? warrantyCard;
  final ReceiptFile? productImage;
  final List<WarrantyCoverage> coverages;

  /// Build from a Firestore document's data map plus its id.
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    final coveragesList = (data['coverages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return Product(
      id: id,
      productName: data['productName'] as String? ?? '',
      brand: data['brand'] as String?,
      category: data['category'] as String? ?? 'Others',
      purchaseDate: data['purchaseDate'] as String? ?? '',
      warrantyDurationMonths:
          (data['warrantyDurationMonths'] as num?)?.toInt() ?? 12,
      serialNumber: data['serialNumber'] as String?,
      modelNumber: data['modelNumber'] as String?,
      notes: data['notes'] as String?,
      receipt: ReceiptFile.fromMap(
        (data['receipt'] as Map?)?.cast<String, dynamic>(),
      ),
      expiryDate: data['expiryDate'] as String? ?? '',
      status: WarrantyStatus.fromWire(data['status'] as String?),
      source: ProductSource.fromWire(data['source'] as String?),
      createdAt: data['createdAt'] as String? ?? '',
      updatedAt: data['updatedAt'] as String? ?? '',
      location: data['location'] as String?,
      shopName: data['shopName'] as String?,
      shopPhoneNumber: data['shopPhoneNumber'] as String?,
      visitingCard: ReceiptFile.fromMap(
        (data['visitingCard'] as Map?)?.cast<String, dynamic>(),
      ),
      warrantyCard: ReceiptFile.fromMap(
        (data['warrantyCard'] as Map?)?.cast<String, dynamic>(),
      ),
      productImage: ReceiptFile.fromMap(
        (data['productImage'] as Map?)?.cast<String, dynamic>(),
      ),
      coverages: coveragesList
          .map((c) => WarrantyCoverage.fromMap(c) ?? const WarrantyCoverage(
                id: '',
                type: 'Manufacturer Warranty',
                duration: 1,
                durationUnit: 'years',
                startDate: '',
              ))
          .toList(),
    );
  }

  /// Serialize for Firestore (id is the doc key, not stored in the body here
  /// to mirror the old app, which also wrote it in — we keep it for parity).
  Map<String, dynamic> toMap() => {
        'id': id,
        'productName': productName,
        'brand': brand,
        'category': category,
        'purchaseDate': purchaseDate,
        'warrantyDurationMonths': warrantyDurationMonths,
        'serialNumber': serialNumber,
        'modelNumber': modelNumber,
        'notes': notes,
        'receipt': receipt?.toMap(),
        'expiryDate': expiryDate,
        'status': status.wire,
        'source': source.wire,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'location': location,
        'shopName': shopName,
        'shopPhoneNumber': shopPhoneNumber,
        'visitingCard': visitingCard?.toMap(),
        'warrantyCard': warrantyCard?.toMap(),
        'productImage': productImage?.toMap(),
        'coverages': coverages.map((c) => c.toMap()).toList(),
      };

  Product copyWith({WarrantyStatus? status, List<WarrantyCoverage>? coverages}) {
    return Product(
      id: id,
      productName: productName,
      brand: brand,
      category: category,
      purchaseDate: purchaseDate,
      warrantyDurationMonths: warrantyDurationMonths,
      serialNumber: serialNumber,
      modelNumber: modelNumber,
      notes: notes,
      receipt: receipt,
      expiryDate: expiryDate,
      status: status ?? this.status,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: location,
      shopName: shopName,
      shopPhoneNumber: shopPhoneNumber,
      visitingCard: visitingCard,
      warrantyCard: warrantyCard,
      productImage: productImage,
      coverages: coverages ?? this.coverages,
    );
  }
}
