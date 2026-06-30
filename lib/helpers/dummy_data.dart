import '../models/product.dart';
import '../services/product_service.dart';

Future<void> addDummyData() async {
  final service = productService;
  final products = await service.getProducts();

  // Only add dummy data if there are no products
  if (products.isNotEmpty) return;

  final today = DateTime.now();
  final isoPast30 = today.subtract(const Duration(days: 30)).toUtc().toIso8601String();
  final isoPast6M = today.subtract(const Duration(days: 180)).toUtc().toIso8601String();

  final dummyProducts = [
    ProductInput(
      productName: 'Samsung Galaxy S23',
      brand: 'Samsung',
      category: 'Electronics',
      purchaseDate: isoPast6M,
      warrantyDurationMonths: 24,
      location: 'Bedroom',
      shopName: 'Star Tech Store',
      shopPhoneNumber: '+8801234567890',
      notes: 'IMEI: 12345678901234',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 1,
          durationUnit: 'years',
          startDate: isoPast6M,
        ),
        WarrantyCoverage(
          id: '2',
          type: 'Extended Warranty',
          duration: 1,
          durationUnit: 'years',
          startDate: isoPast6M,
        ),
      ],
    ),
    ProductInput(
      productName: 'LG 55" Smart TV',
      brand: 'LG',
      category: 'Electronics',
      purchaseDate: isoPast30,
      warrantyDurationMonths: 36,
      location: 'Living Room',
      shopName: 'Electronics World',
      shopPhoneNumber: '+8809876543210',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 3,
          durationUnit: 'years',
          startDate: isoPast30,
        ),
      ],
    ),
    ProductInput(
      productName: 'Apple MacBook Pro',
      brand: 'Apple',
      category: 'Electronics',
      purchaseDate: today.subtract(const Duration(days: 365)).toUtc().toIso8601String(),
      warrantyDurationMonths: 12,
      location: 'Office',
      shopName: 'Apple Store',
      shopPhoneNumber: '+8801111111111',
      notes: 'Serial: A1234B5678C',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 1,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 365)).toUtc().toIso8601String(),
        ),
        WarrantyCoverage(
          id: '2',
          type: 'AppleCare+',
          duration: 2,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 365)).toUtc().toIso8601String(),
        ),
      ],
    ),
    ProductInput(
      productName: 'Whirlpool Refrigerator',
      brand: 'Whirlpool',
      category: 'Home Appliances',
      purchaseDate: today.subtract(const Duration(days: 120)).toUtc().toIso8601String(),
      warrantyDurationMonths: 24,
      location: 'Kitchen',
      shopName: 'Home Appliance Plus',
      shopPhoneNumber: '+8802222222222',
      notes: 'Model: WF45R6100AW',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 2,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 120)).toUtc().toIso8601String(),
        ),
        WarrantyCoverage(
          id: '2',
          type: 'Compressor Warranty',
          duration: 5,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 120)).toUtc().toIso8601String(),
        ),
      ],
    ),
    ProductInput(
      productName: 'Sony WH-1000XM5 Headphones',
      brand: 'Sony',
      category: 'Electronics',
      purchaseDate: today.subtract(const Duration(days: 60)).toUtc().toIso8601String(),
      warrantyDurationMonths: 12,
      location: 'Home',
      shopName: 'Audio Warehouse',
      shopPhoneNumber: '+8803333333333',
      notes: 'Color: Black',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 1,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 60)).toUtc().toIso8601String(),
        ),
        WarrantyCoverage(
          id: '2',
          type: 'Battery Warranty',
          duration: 2,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 60)).toUtc().toIso8601String(),
        ),
      ],
    ),
    ProductInput(
      productName: 'Ikea Sofa',
      brand: 'Ikea',
      category: 'Furniture',
      purchaseDate: today.subtract(const Duration(days: 200)).toUtc().toIso8601String(),
      warrantyDurationMonths: 60,
      location: 'Living Room',
      shopName: 'Ikea Store',
      shopPhoneNumber: '+8804444444444',
      coverages: [
        WarrantyCoverage(
          id: '1',
          type: 'Manufacturer Warranty',
          duration: 5,
          durationUnit: 'years',
          startDate: today.subtract(const Duration(days: 200)).toUtc().toIso8601String(),
        ),
      ],
    ),
  ];

  for (final product in dummyProducts) {
    await service.createProduct(product);
  }
}
