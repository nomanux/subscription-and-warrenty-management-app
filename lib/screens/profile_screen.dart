/// Profile page — account header, a quick stat, and settings entries.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../core/providers/theme_provider.dart';
import '../core/providers/user_provider.dart';
import '../features/backup/presentation/screens/backup_screen.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  void _pickProfileImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref.read(userProvider.notifier).updateProfileImage(image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated')),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    userAsync.whenData((user) {
      final nameController = TextEditingController(text: user.name ?? '');
      final phoneController =
          TextEditingController(text: user.phoneNumber ?? '');
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: kCardShadow,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUserEdit01,
                            color: kPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                              Text(
                                'Update your profile information',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Name field
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUserCircle,
                            color: kPrimary,
                            size: 20,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kMuted, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kMuted, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: kPrimary, width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone field
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCall,
                            color: kPrimary,
                            size: 20,
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kMuted, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kMuted, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: kPrimary, width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Phone number cannot be empty';
                        }
                        if (value!.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(
                                color: kMuted,
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: kInk,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final updatedUser = user.copyWith(
                                  name: nameController.text.isEmpty
                                      ? null
                                      : nameController.text,
                                  phoneNumber: phoneController.text.isEmpty
                                      ? null
                                      : phoneController.text,
                                );
                                ref
                                    .read(userProvider.notifier)
                                    .updateUser(updatedUser);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      '✅ Profile updated successfully',
                                    ),
                                    backgroundColor: kPrimary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeModeProvider);
    final userAsync = ref.watch(userProvider);

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
                GestureDetector(
                  onTap: () => _pickProfileImage(context, ref),
                  child: Stack(
                    children: [
                      userAsync.when(
                        data: (user) {
                          if (user.profileImagePath != null &&
                              user.profileImagePath!.isNotEmpty &&
                              File(user.profileImagePath!).existsSync()) {
                            return CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  FileImage(File(user.profileImagePath!)),
                            );
                          }
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUserCircle,
                                color: Colors.white,
                                size: 44),
                          );
                        },
                        loading: () => CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.22),
                          child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserCircle,
                              color: Colors.white,
                              size: 44),
                        ),
                        error: (_, _) => CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.22),
                          child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUserCircle,
                              color: Colors.white,
                              size: 44),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCamera01,
                            color: kPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                userAsync.when(
                  data: (user) => Column(
                    children: [
                      Text(
                        user.name ?? 'Warranty Vault User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.phoneNumber ?? 'Local account',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  loading: () => Column(
                    children: [
                      const Text(
                        'Warranty Vault User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Local account',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  error: (_, _) => Column(
                    children: [
                      const Text(
                        'Warranty Vault User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Local account',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _showEditProfileDialog(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit Profile'),
                ),
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
                _ThemeToggleTile(
                  isDarkMode: isDarkMode,
                  onToggle: () {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
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

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile({
    required this.isDarkMode,
    required this.onToggle,
  });

  final bool isDarkMode;
  final VoidCallback onToggle;

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
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedPaintBoard,
              color: kPrimary,
              size: 20,
            ),
          ),
          title: const Text(
            'Appearance',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: kInk,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            isDarkMode ? 'Dark mode' : 'Light mode',
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (_) => onToggle(),
            activeThumbColor: kPrimary,
          ),
        ),
      ),
    );
  }
}
