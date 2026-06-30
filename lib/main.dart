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
import 'package:warranty_vault/core/database/app_database.dart';

import 'core/providers/theme_provider.dart';
import 'features/auth/data/google_auth_service.dart';
import 'features/backup/services/drive_backup_service.dart';
import 'dev/seed_local.dart';
import 'firebase_options.dart';
import 'helpers/dummy_data.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/splash_screen.dart';
import 'services/product_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the flutter_twind styling system (Tailwind-style classNames).
  WindConfig.initialize();

  // Defer all heavy initialization until after splash screen
  // Init in background to allow app to start immediately
  _initializeAppAsync();

  runApp(const ProviderScope(child: WarrantyVaultApp()));
}

// Initialize all heavy services in background (non-blocking)
Future<void> _initializeAppAsync() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error (non-fatal): $e');
  }

  // Initialize local database in background
  try {
    final db = AppDatabase();
    productService.setLocalDatabase(db);
    await seedLocalIfEmpty(db);
    // Add dummy data if none exist
    await addDummyData();
  } catch (e) {
    debugPrint('Database initialization error (non-fatal): $e');
  }
}

class WarrantyVaultApp extends ConsumerWidget {
  const WarrantyVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Warantee',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: () {});
    }
    return const HomeShell();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Google auth for Drive backup (silent, deferred from startup)
    _initializeGoogleAuth();
    // Daily auto-backup to Google Drive (no-op if not connected / done today).
    DriveBackupService.instance.maybeAutoBackup();
  }

  Future<void> _initializeGoogleAuth() async {
    try {
      await GoogleAuthService.instance.init();
    } catch (e) {
      debugPrint('Google auth initialization error (non-fatal): $e');
    }
  }

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: _go),
      const ProductsScreen(),
      const RemindersScreen(),
      ProfileScreen(onNavigate: _go),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: kSurface,
          height: 66,
          padding: EdgeInsets.zero,
          elevation: 0,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top indicator bar when selected
            if (selected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 3, color: kPrimary),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HugeIcon(icon: icon, color: color, size: 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
