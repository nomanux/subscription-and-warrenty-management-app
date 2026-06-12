/// Warranty Vault — Flutter entry point.
///
/// Five destinations expressed as four labelled tabs (Home, Warranties,
/// Reminders, Profile) plus a center floating "+" button for Add.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:warranty_vault/core/database/app_database.dart';

import 'core/providers/app_providers.dart';
import 'core/providers/theme_provider.dart';
import 'dev/seed_local.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the flutter_twind styling system (Tailwind-style classNames).
  WindConfig.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Seed demo data disabled temporarily while we debug
  // TODO: Re-enable after fixing initialization issue
  // try {
  //   await productService.seedDemoDataIfEmpty().timeout(
  //     const Duration(seconds: 5),
  //     onTimeout: () => debugPrint('Seeding timeout - continuing anyway'),
  //   );
  // } catch (e) {
  //   debugPrint('Demo data seeding error (non-fatal): $e');
  // }

  // Seed Firestore with demo data including receipt images
  try {
    await _seedFirestoreDemoData();
  } catch (e) {
    debugPrint('Firestore seeding error (non-fatal): $e');
  }

  // Initialize local database (non-blocking, ignore errors)
  try {
    final db = AppDatabase();
    await seedLocalIfEmpty(db);
    runApp(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WarrantyVaultApp(),
      ),
    );
  } catch (e) {
    debugPrint('Database initialization error (non-fatal): $e');
    // App can function without local DB - using Firestore
    runApp(const ProviderScope(child: WarrantyVaultApp()));
  }
}

/// Seed Firestore with demo warranties including receipt images
Future<void> _seedFirestoreDemoData() async {
  final db = FirebaseFirestore.instance;
  final productsRef = db.collection('products');

  // Check if we need to reseed (if products exist but have no receipt images)
  final snapshot = await productsRef.limit(1).get();

  if (snapshot.docs.isNotEmpty) {
    // Check if the existing product has a receipt
    final firstDoc = snapshot.docs.first.data();
    if (firstDoc['receipt'] != null) {
      // Already seeded with receipts, skip
      return;
    }
    // Has products but no receipts - delete and reseed
    final allDocs = await productsRef.get();
    for (var doc in allDocs.docs) {
      await doc.reference.delete();
    }
  }

  // Color placeholder images as base64 PNG (1x1 pixels)
  const images = {
    'Instant Hotpot': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==', // red
    'MacBook Pro 14"': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12P4z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==', // blue
    'iPhone 15': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADElEQVQI12NgYGBgAAAABAABSK+kcQAAAABJRU5ErkJggg==', // black
    'Anker PowerBank': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP4//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==', // yellow
    'Ceiling Fan': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', // gray
    'Office Chair': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', // brown
    'Toyota Corolla': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEBAH/wlseKgAAAABJRU5ErkJggg==', // white
    'Electric Kettle': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8//8/AwAI/AL+O3DfsAAAAABJRU5ErkJggg==', // orange
    'Wrist Watch': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==', // purple
    'Headphones': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==', // red
    'Blender': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', // green
    'Motorcycle': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==', // red
  };

  const demoItems = [
    ('seed-001', 'Instant Hotpot', 'Home Appliances', '2025-09-01', 24, 'Daraz', true),
    ('seed-002', 'MacBook Pro 14"', 'Electronics', '2025-12-10', 12, 'Apple Store', true),
    ('seed-003', 'iPhone 15', 'Electronics', '2026-01-05', 24, 'Apple Store', false),
    ('seed-004', 'Anker PowerBank', 'Electronics', '2026-03-15', 18, 'Amazon', true),
    ('seed-005', 'Ceiling Fan', 'Home Appliances', '2025-11-20', 36, 'Singer', false),
    ('seed-006', 'Office Chair', 'Furniture', '2026-01-20', 24, 'IKEA', true),
    ('seed-007', 'Toyota Corolla', 'Vehicle', '2025-08-15', 36, 'Toyota', false),
    ('seed-008', 'Electric Kettle', 'Home Appliances', '2025-06-20', 12, 'Philips', true),
    ('seed-009', 'Wrist Watch', 'Others', '2024-06-25', 24, 'Casio', false),
    ('seed-010', 'Headphones', 'Electronics', '2024-07-02', 24, 'Sony Center', true),
    ('seed-011', 'Blender', 'Home Appliances', '2023-01-10', 12, 'Nutribullet', false),
    ('seed-012', 'Motorcycle', 'Vehicle', '2021-03-01', 36, 'Honda', true),
  ];

  final now = DateTime.now().toUtc().toIso8601String();

  for (final (id, name, category, purchase, months, _, hasImage) in demoItems) {
    final purchaseDate = DateTime.parse(purchase);
    final expiryDate = purchaseDate.add(Duration(days: months * 30));
    final imageUri = hasImage ? (images[name] ?? images['Instant Hotpot']!) : null;

    try {
      final data = {
        'id': id,
        'productName': name,
        'brand': null,
        'category': category,
        'purchaseDate': purchase,
        'warrantyDurationMonths': months,
        'serialNumber': null,
        'modelNumber': null,
        'notes': null,
        'expiryDate': expiryDate.toUtc().toIso8601String(),
        'status': _computeStatus(expiryDate),
        'source': 'manual',
        'createdAt': now,
        'updatedAt': now,
      };

      // Only add receipt if item has image
      if (hasImage && imageUri != null) {
        data['receipt'] = {
          'uri': imageUri,
          'fileType': 'image',
          'thumbnailUri': null,
        };
      }

      await productsRef.doc(id).set(data);
      debugPrint('Seeded warranty: $name ${hasImage ? 'with' : 'without'} image');
    } catch (e) {
      debugPrint('Error seeding $name: $e');
    }
  }
}

String _computeStatus(DateTime expiryDate) {
  final days = DateTime.now().difference(expiryDate).inDays;
  if (days > 0) return 'expired';
  if (days > -30) return 'expiring';
  return 'active';
}

class WarrantyVaultApp extends ConsumerWidget {
  const WarrantyVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Warranty Vault',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: _go),
      const ProductsScreen(),
      const _PlaceholderScreen(
        title: 'Reminders',
        icon: HugeIcons.strokeRoundedNotification01,
        message: 'Expiry reminders will appear here.',
      ),
      ProfileScreen(onNavigate: _go),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomAppBar(
        color: kSurface,
        height: 66,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _NavItem(
              icon: HugeIcons.strokeRoundedHome01,
              label: 'Home',
              selected: _index == 0,
              onTap: () => _go(0),
            ),
            _NavItem(
              icon: HugeIcons.strokeRoundedFile01,
              label: 'Warranties',
              selected: _index == 1,
              onTap: () => _go(1),
            ),
            _NavItem(
              icon: HugeIcons.strokeRoundedNotification01,
              label: 'Reminders',
              selected: _index == 2,
              onTap: () => _go(2),
            ),
            _NavItem(
              icon: HugeIcons.strokeRoundedUserCircle,
              label: 'Profile',
              selected: _index == 3,
              onTap: () => _go(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled bottom-bar item.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? kPrimary : kMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Simple "coming soon" screen for tabs not yet built (Reminders).
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final List<List<dynamic>> icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: kPrimary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: kInk, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(color: kMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
