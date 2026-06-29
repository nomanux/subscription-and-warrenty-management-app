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
    final googleAccountAsync = ref.watch(googleAccountProvider);
    final googleAccount = googleAccountAsync.asData?.value;

    // If Google account is connected, use it (regardless of isGoogleLogin flag)
    // Otherwise fall back to local account
    final displayName =
        googleAccount?.displayName ?? userAuthState.username ?? 'Warantee';
    final email = googleAccount?.email ?? userAuthState.email;

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
                // Show Google photo with white border, or profile avatar with initials
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: googleAccount?.photoUrl?.isNotEmpty == true
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.25),
                    backgroundImage:
                        googleAccount?.photoUrl?.isNotEmpty == true
                            ? NetworkImage(googleAccount!.photoUrl!)
                            : null,
                    child: googleAccount?.photoUrl?.isNotEmpty != true
                        ? Text(
                            _getInitials(displayName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                if (email != null)
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
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
