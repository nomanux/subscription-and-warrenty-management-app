/// Profile page — account header, a quick stat, and settings entries.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../features/backup/presentation/screens/backup_screen.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header.
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPadding + 28, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimary, kPrimaryDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUserCircle,
                      color: Colors.white,
                      size: 44),
                ),
                const SizedBox(height: 12),
                const Text('Warranty Vault User',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700)),
                Text('Local account',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick stat.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<Product>>(
              stream: productService.watchProducts(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return _StatStrip(total: count);
              },
            ),
          ),
          const SizedBox(height: 20),
          // Settings entries.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _SettingTile(
                  icon: HugeIcons.strokeRoundedCloudUpload,
                  title: 'Backup & Restore',
                  subtitle: 'Google Drive',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  ),
                ),
                _SettingTile(
                  icon: HugeIcons.strokeRoundedNotification01,
                  title: 'Reminders',
                  subtitle: 'Expiry notifications',
                  onTap: () => onNavigate(2),
                ),
                _SettingTile(
                  icon: HugeIcons.strokeRoundedPaintBoard,
                  title: 'Appearance',
                  subtitle: 'Theme & dark mode',
                  onTap: () => _comingSoon(context, 'Dark mode'),
                ),
                _SettingTile(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Warranty Vault',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Never lose a warranty again.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: HugeIcon(
                icon: HugeIcons.strokeRoundedShield01,
                color: kPrimary,
                size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$total',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kInk)),
              const Text('warranties tracked',
                  style: TextStyle(color: kMuted, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: HugeIcon(icon: icon, color: kPrimary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: kInk, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: kMuted, fontSize: 12)),
        trailing: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight01,
            color: kMuted,
            size: 18),
        onTap: onTap,
        ),
      ),
    );
  }
}
