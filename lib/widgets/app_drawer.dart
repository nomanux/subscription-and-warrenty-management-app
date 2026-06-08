/// Left-side navigation drawer for the app (opened from the Home menu button).
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

class AppDrawer extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  child: HugeIcon(
                      icon: HugeIcons.strokeRoundedShield01,
                      color: Colors.white,
                      size: 28),
                ),
                const SizedBox(height: 12),
                const Text('Warranty Vault',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Local account',
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
            icon: HugeIcons.strokeRoundedCloudUpload,
            label: 'Backup & Restore',
            selected: false,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Google Drive backup is coming soon.')));
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
                applicationName: 'Warranty Vault',
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
