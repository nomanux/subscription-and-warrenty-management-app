/// Manage custom warranty categories with icon selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/providers/categories_provider.dart';
import '../models/category.dart';
import '../theme.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            );
          }

          final category = categories[index];
          return _CategoryTile(
            category: category,
            onEdit: () => _showEditCategoryDialog(context, ref, category),
            onDelete: () => ref.read(categoriesProvider.notifier).removeCategory(category.name),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    _showCategoryDialog(context, ref, null);
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, WCategory category) {
    _showCategoryDialog(context, ref, category);
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, WCategory? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.iconName ?? 'strokeRoundedShoppingBag01';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit', style: const TextStyle(fontSize: 18)),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Electronics',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Icon',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  shrinkWrap: true,
                  itemCount: _iconOptions.length,
                  itemBuilder: (itemContext, index) {
                    final iconName = _iconOptions[index];
                    final icon = _getIconFromName(iconName);
                    final isSelected = selectedIcon == iconName;

                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = iconName),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? kPrimary : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? kPrimary.withValues(alpha: 0.1) : null,
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: icon,
                            color: isSelected ? kPrimary : kMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter name')),
                  );
                  return;
                }

                final newCategory = WCategory(name: name, iconName: selectedIcon);

                if (category == null) {
                  ref.read(categoriesProvider.notifier).addCategory(newCategory);
                } else {
                  ref.read(categoriesProvider.notifier).updateCategory(category.name, newCategory);
                }

                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final WCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = _getIconFromName(category.iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(
              icon: icon,
              color: kPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kInk,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 0),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: onDelete,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 0),
              foregroundColor: kMuted,
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// List of available HugeIcon options
const List<String> _iconOptions = [
  'strokeRoundedShoppingCart01',
  'strokeRoundedHome01',
  'strokeRoundedTag01',
  'strokeRoundedFile01',
  'strokeRoundedCar01',
  'strokeRoundedShoppingBag01',
  'strokeRoundedCloudUpload',
  'strokeRoundedNotification01',
  'strokeRoundedShield01',
  'strokeRoundedAlertCircle',
  'strokeRoundedSettings01',
  'strokeRoundedSearch01',
  'strokeRoundedFilter',
  'strokeRoundedRefresh01',
  'strokeRoundedDownload01',
  'strokeRoundedPackage',
  'strokeRoundedCalendar03',
  'strokeRoundedBook01',
  'strokeRoundedBriefcase01',
  'strokeRoundedCamera01',
  'strokeRoundedCloudDownload',
  'strokeRoundedClock01',
  'strokeRoundedClock02',
  'strokeRoundedDelete01',
  'strokeRoundedEdit01',
  'strokeRoundedEye',
  'strokeRoundedFire',
  'strokeRoundedFolder01',
  'strokeRoundedGift',
  'strokeRoundedGlobe',
  'strokeRoundedHelpCircle',
  'strokeRoundedKey01',
  'strokeRoundedLeaf01',
  'strokeRoundedLayout01',
  'strokeRoundedLayoutRight',
  'strokeRoundedLink01',
  'strokeRoundedLock',
  'strokeRoundedMail01',
  'strokeRoundedMapPin',
  'strokeRoundedMoney02',
];

List<List<dynamic>> _getIconFromName(String iconName) {
  switch (iconName) {
    case 'strokeRoundedShoppingCart01':
      return HugeIcons.strokeRoundedShoppingCart01;
    case 'strokeRoundedHome01':
      return HugeIcons.strokeRoundedHome01;
    case 'strokeRoundedTag01':
      return HugeIcons.strokeRoundedTag01;
    case 'strokeRoundedFile01':
      return HugeIcons.strokeRoundedFile01;
    case 'strokeRoundedCar01':
      return HugeIcons.strokeRoundedCar01;
    case 'strokeRoundedShoppingBag01':
      return HugeIcons.strokeRoundedShoppingBag01;
    case 'strokeRoundedCloudUpload':
      return HugeIcons.strokeRoundedCloudUpload;
    case 'strokeRoundedNotification01':
      return HugeIcons.strokeRoundedNotification01;
    case 'strokeRoundedShield01':
      return HugeIcons.strokeRoundedShield01;
    case 'strokeRoundedAlertCircle':
      return HugeIcons.strokeRoundedAlertCircle;
    case 'strokeRoundedSettings01':
      return HugeIcons.strokeRoundedSettings01;
    case 'strokeRoundedSearch01':
      return HugeIcons.strokeRoundedSearch01;
    case 'strokeRoundedFilter':
      return HugeIcons.strokeRoundedFilter;
    case 'strokeRoundedRefresh01':
      return HugeIcons.strokeRoundedRefresh01;
    case 'strokeRoundedDownload01':
      return HugeIcons.strokeRoundedDownload01;
    case 'strokeRoundedPackage':
      return HugeIcons.strokeRoundedPackage;
    case 'strokeRoundedCalendar03':
      return HugeIcons.strokeRoundedCalendar03;
    case 'strokeRoundedBook01':
      return HugeIcons.strokeRoundedBook01;
    case 'strokeRoundedBriefcase01':
      return HugeIcons.strokeRoundedBriefcase01;
    case 'strokeRoundedCamera01':
      return HugeIcons.strokeRoundedCamera01;
    case 'strokeRoundedCloudDownload':
      return HugeIcons.strokeRoundedCloudDownload;
    case 'strokeRoundedClock01':
      return HugeIcons.strokeRoundedClock01;
    case 'strokeRoundedClock02':
      return HugeIcons.strokeRoundedClock02;
    case 'strokeRoundedDelete01':
      return HugeIcons.strokeRoundedDelete01;
    case 'strokeRoundedEdit01':
      return HugeIcons.strokeRoundedEdit01;
    case 'strokeRoundedEye':
      return HugeIcons.strokeRoundedEye;
    case 'strokeRoundedFire':
      return HugeIcons.strokeRoundedFire;
    case 'strokeRoundedFolder01':
      return HugeIcons.strokeRoundedFolder01;
    case 'strokeRoundedGift':
      return HugeIcons.strokeRoundedGift;
    case 'strokeRoundedGlobe':
      return HugeIcons.strokeRoundedGlobe;
    case 'strokeRoundedHelpCircle':
      return HugeIcons.strokeRoundedHelpCircle;
    case 'strokeRoundedKey01':
      return HugeIcons.strokeRoundedKey01;
    case 'strokeRoundedLeaf01':
      return HugeIcons.strokeRoundedLeaf01;
    case 'strokeRoundedLayout01':
      return HugeIcons.strokeRoundedLayout01;
    case 'strokeRoundedLayoutRight':
      return HugeIcons.strokeRoundedLayoutRight;
    case 'strokeRoundedLink01':
      return HugeIcons.strokeRoundedLink01;
    case 'strokeRoundedLock':
      return HugeIcons.strokeRoundedLock;
    case 'strokeRoundedMail01':
      return HugeIcons.strokeRoundedMail01;
    case 'strokeRoundedMapPin':
      return HugeIcons.strokeRoundedMapPin;
    case 'strokeRoundedMoney02':
      return HugeIcons.strokeRoundedMoney02;
    default:
      return HugeIcons.strokeRoundedShoppingBag01;
  }
}
