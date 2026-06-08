/// My Warranties screen — list of all products with add/edit/delete.
///
/// Direct port of the React Native `products.tsx`. Uses a live Firestore
/// stream so the list updates instantly after create/edit/delete.
library;

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete warranty?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await productService.deleteProduct(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Warranties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductForm(context),
        icon: HugeIcon(
            icon: HugeIcons.strokeRoundedPlusSign, color: Colors.white),
        label: const Text('Add'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.watchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load warranties.\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final product = products[i];
              return ProductCard(
                product: product,
                onEdit: (p) => showProductForm(context, initial: p),
                onDelete: (id) => _confirmDelete(context, id),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: WColumn(
          mainAxisSize: MainAxisSize.min,
          children: const [
            WText('🗂️', fontSize: 48),
            SizedBox(height: 8),
            WText('Your vault is empty',
                color: kInk, fontSize: 22, className: 'font-bold'),
            SizedBox(height: 4),
            WText(
              'Tap “Add” to track your first warranty.',
              color: kMuted,
              fontSize: 14,
              className: 'text-center',
            ),
          ],
        ),
      ),
    );
  }
}
