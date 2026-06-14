/// Left-side navigation drawer for the app (opened from the Home menu button).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../features/auth/presentation/providers/google_auth_provider.dart';
import '../features/auth/presentation/providers/user_auth_provider.dart';
import '../features/auth/presentation/screens/google_connect_screen.dart';
import '../features/backup/presentation/screens/backup_screen.dart';
import '../theme.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  /// Currently selected bottom-nav index (for highlight).
  final int currentIndex;

  /// Switch the app's main tab.
  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAuthState = ref.watch(userAuthStateProvider);
    final googleAccount = userAuthState.isGoogleLogin
        ? ref.watch(googleAccountProvider).asData?.value
        : null;

    // Get display name and email
    final displayName =
        googleAccount?.displayName ?? userAuthState.username ?? 'Warantee User';
    final email = googleAccount?.email ?? userAuthState.email ?? 'Local account';

    return Drawer(
      backgroundColor: kSurface,
      child: Column(
        children: [
          // Gradient header.
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimary, kPrimaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show Google photo if available, otherwise icon
                if (googleAccount?.photoUrl?.isNotEmpty ?? false)
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        NetworkImage(googleAccount!.photoUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    child: HugeIcon(
                        icon: HugeIcons.strokeRoundedShield01,
                        color: Colors.white,
                        size: 28),
                  ),
                const SizedBox(height: 12),
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text(email,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _NavTile(
            icon: HugeIcons.strokeRoundedHome01,
            label: 'Dashboard',
            selected: currentIndex == 0,
            onTap: () => _go(context, 0),
          ),
          _NavTile(
            icon: HugeIcons.strokeRoundedFile01,
            label: 'My Warranties',
            selected: currentIndex == 1,
            onTap: () => _go(context, 1),
          ),
          _NavTile(
            icon: HugeIcons.strokeRoundedNotification01,
            label: 'Reminders',
            selected: currentIndex == 2,
            onTap: () => _go(context, 2),
          ),
          _NavTile(
            icon: HugeIcons.strokeRoundedUserCircle,
            label: 'Profile',
            selected: currentIndex == 3,
            onTap: () => _go(context, 3),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),
          _NavTile(
            icon: HugeIcons.strokeRoundedGoogle,
            label: 'Connect Google',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GoogleConnectScreen()),
              );
            },
          ),
          _NavTile(
            icon: HugeIcons.strokeRoundedCloudUpload,
            label: 'Backup & Restore',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BackupScreen()),
              );
            },
          ),
          _NavTile(
            icon: HugeIcons.strokeRoundedInformationCircle,
            label: 'About',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Warantee',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Never lose a warranty again.',
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('v1.0.0',
                style: TextStyle(color: kMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, int index) {
    Navigator.pop(context);
    onNavigate(index);
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
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
    return ListTile(
      leading: HugeIcon(icon: icon, color: color, size: 22),
      title: Text(label,
          style: TextStyle(
              color: selected ? kPrimary : kInk,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      selected: selected,
      selectedTileColor: kPrimary.withValues(alpha: 0.08),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: onTap,
    );
  }
}
