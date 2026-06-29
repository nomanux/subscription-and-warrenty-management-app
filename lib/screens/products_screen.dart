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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String searchQuery = '';
  late final ValueNotifier<String?> expandedProductId;
  late final ValueNotifier<WarrantyStatus?> selectedFilter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    expandedProductId = ValueNotifier<String?>(null);
    selectedFilter = ValueNotifier<WarrantyStatus?>(null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    expandedProductId.dispose();
    selectedFilter.dispose();
    super.dispose();
  }

  void _handleExpandProduct(Product product) {
    expandedProductId.value = expandedProductId.value == product.id ? null : product.id;
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Apply status filter
    if (selectedFilter.value != null) {
      filtered = filtered.where((p) => p.status == selectedFilter.value).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.productName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (p.brand?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                    false) ||
                p.category.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Warranties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductForm(context),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
                child: Text(
                  'Could not load warranties.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const _EmptyState();
          }

          return Column(
            children: [
              // Search bar - above filters
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search Items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                            child: const Icon(Icons.close),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<WarrantyStatus?>(
                valueListenable: selectedFilter,
                builder: (context, currentFilter, _) {
                  return _FilterBar(
                    selectedFilter: currentFilter,
                    onFilterChanged: (filter) =>
                        selectedFilter.value = filter,
                  );
                },
              ),
              Expanded(
                child: ValueListenableBuilder<WarrantyStatus?>(
                  valueListenable: selectedFilter,
                  builder: (context, _, _) {
                    final filteredForDisplay = _filterProducts(products);
                    return filteredForDisplay.isEmpty
                        ? _NoResultsState(
                            filter: selectedFilter.value,
                            searchQuery: searchQuery,
                          )
                        : ValueListenableBuilder<String?>(
                            valueListenable: expandedProductId,
                            builder: (context, expandedId, _) {
                              return RepaintBoundary(
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                                  children: [
                                    ...filteredForDisplay.map((product) {
                                      final isExpanded = expandedId == product.id;
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                                        child: ProductCard(
                                          key: ValueKey(product.id),
                                          product: product,
                                          isExpanded: isExpanded,
                                          onExpand: () =>
                                              _handleExpandProduct(product),
                                          onViewDetails: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ProductDetailScreen(
                                                    initial: product,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
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
            WText(
              'Your vault is empty',
              color: kInk,
              fontSize: 22,
              className: 'font-bold',
            ),
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final WarrantyStatus? selectedFilter;
  final Function(WarrantyStatus?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selectedFilter == null,
              onTap: () => onFilterChanged(null),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Active',
              isSelected: selectedFilter == WarrantyStatus.active,
              onTap: () => onFilterChanged(WarrantyStatus.active),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Expiring Soon',
              isSelected: selectedFilter == WarrantyStatus.expiring,
              onTap: () => onFilterChanged(WarrantyStatus.expiring),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Expired',
              isSelected: selectedFilter == WarrantyStatus.expired,
              onTap: () => onFilterChanged(WarrantyStatus.expired),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: WText(
        label,
        fontSize: 13,
        color: isSelected ? Colors.white : kInk,
        className: 'font-medium',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: kPrimary,
      showCheckmark: false,
      side: BorderSide(
        color: isSelected ? kPrimary : const Color(0xFFD1D5DB),
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.filter, this.searchQuery = ''});

  final WarrantyStatus? filter;
  final String searchQuery;

  String get _filterLabel {
    switch (filter) {
      case WarrantyStatus.active:
        return 'active';
      case WarrantyStatus.expiring:
        return 'expiring soon';
      case WarrantyStatus.expired:
        return 'expired';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchQuery.isNotEmpty;
    final message = hasSearch
        ? 'No warranties found for\n"$searchQuery"'
        : filter == null
        ? 'No warranties yet'
        : 'No $_filterLabel warranties';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: WColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            WText(hasSearch ? '🔍' : '📭', fontSize: 48),
            const SizedBox(height: 8),
            WText(message, color: kInk, fontSize: 22, className: 'font-bold'),
            const SizedBox(height: 4),
            WText(
              'Try adjusting your filter.',
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
