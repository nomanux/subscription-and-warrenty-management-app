/// Riverpod provider for managing custom warranty categories.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category.dart';

// Default categories
const List<WCategory> _defaultCategories = [
  WCategory(name: 'Electronics', iconName: 'strokeRoundedShoppingCart01'),
  WCategory(name: 'Home Appliances', iconName: 'strokeRoundedHome01'),
  WCategory(name: 'Kitchen Appliances', iconName: 'strokeRoundedChefHat01'),
  WCategory(name: 'Furniture', iconName: 'strokeRoundedArmchair01'),
  WCategory(name: 'Vehicle', iconName: 'strokeRoundedCar01'),
  WCategory(name: 'Others', iconName: 'strokeRoundedShoppingBag01'),
];

class CategoriesNotifier extends Notifier<List<WCategory>> {
  @override
  List<WCategory> build() {
    _loadCategories();
    return _defaultCategories;
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('categories');

      if (saved == null || saved.isEmpty) {
        state = _defaultCategories;
        await _saveCategories(_defaultCategories);
      } else {
        final decoded = jsonDecode(saved) as List<dynamic>;
        final categories = decoded
            .map((c) => WCategory.fromMap(c as Map<String, dynamic>))
            .toList();
        state = categories;
      }
    } catch (e) {
      state = _defaultCategories;
    }
  }

  Future<void> _saveCategories(List<WCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(categories.map((c) => c.toMap()).toList());
      await prefs.setString('categories', encoded);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addCategory(WCategory category) async {
    if (state.any((c) => c.name == category.name)) return;
    final updated = [...state, category];
    state = updated;
    await _saveCategories(updated);
  }

  Future<void> removeCategory(String name) async {
    final updated = state.where((c) => c.name != name).toList();
    state = updated;
    await _saveCategories(updated);
  }

  Future<void> updateCategory(String oldName, WCategory newCategory) async {
    final updated = state.map((c) => c.name == oldName ? newCategory : c).toList();
    state = updated;
    await _saveCategories(updated);
  }

  Future<void> resetToDefaults() async {
    state = _defaultCategories;
    await _saveCategories(_defaultCategories);
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<WCategory>>(() {
  return CategoriesNotifier();
});
