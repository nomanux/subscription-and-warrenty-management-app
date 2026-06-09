/// My Warranties screen — list of all products with add/edit/delete.
///
/// Direct port of the React Native `products.tsx`. Uses a live Firestore
/// stream so the list updates instantly after create/edit/delete.
library;

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Warranties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductForm(context),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(initial: product),
                  ),
                ),
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
