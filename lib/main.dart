/// Warranty Vault — Flutter entry point.
///
/// Five destinations expressed as four labelled tabs (Home, Warranties,
/// Reminders, Profile) plus a center floating "+" button for Add.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';

import 'core/database/app_database.dart';
import 'core/providers/app_providers.dart';
import 'dev/seed_local.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';
import 'widgets/product_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the flutter_twind styling system (Tailwind-style classNames).
  WindConfig.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Open the local Drift DB once and seed demo data on first launch.
  final db = AppDatabase();
  await seedLocalIfEmpty(db);
  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const WarrantyVaultApp(),
    ),
  );
}

class WarrantyVaultApp extends StatelessWidget {
  const WarrantyVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warranty Vault',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductForm(context),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: HugeIcon(
            icon: HugeIcons.strokeRoundedPlusSign,
            color: Colors.white,
            size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: kSurface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
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
            const SizedBox(width: 56), // gap for the center FAB
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
