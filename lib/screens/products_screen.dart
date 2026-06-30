/// My Warranties screen — list of all products with add/edit/delete.
///
/// Direct port of the React Native `products.tsx`. Uses a live Firestore
/// stream so the list updates instantly after create/edit/delete.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';

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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    expandedProductId = ValueNotifier<String?>(null);
    selectedFilter = ValueNotifier<WarrantyStatus?>(null);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    expandedProductId.dispose();
    selectedFilter.dispose();
    super.dispose();
  }

  void _handleExpandProduct(Product product) {
    expandedProductId.value = expandedProductId.value == product.id
        ? null
        : product.id;
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Apply status filter
    if (selectedFilter.value != null) {
      filtered = filtered
          .where((p) => p.status == selectedFilter.value)
          .toList();
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

  Future<void> _deleteProduct(Product product) async {
    try {
      await productService.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: _DeleteSnackBarContent(
              productName: product.productName,
              onUndo: () => _undoDelete(product),
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 6,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  Future<void> _undoDelete(Product product) async {
    try {
      await productService.createProduct(
        ProductInput(
          productName: product.productName,
          brand: product.brand,
          category: product.category,
          purchaseDate: product.purchaseDate,
          warrantyDurationMonths: product.warrantyDurationMonths,
          serialNumber: product.serialNumber,
          modelNumber: product.modelNumber,
          notes: product.notes,
          receipt: product.receipt,
          location: product.location,
          shopName: product.shopName,
          shopPhoneNumber: product.shopPhoneNumber,
          visitingCard: product.visitingCard,
          warrantyCard: product.warrantyCard,
          productImage: product.productImage,
          coverages: product.coverages,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error undoing delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductForm(context),
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: Colors.white),
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

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom header
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'My Warranties',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kInk,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'All your warranties in one place',
                            style: TextStyle(fontSize: 13, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(
                          const Duration(milliseconds: 300),
                          () {
                            setState(() => searchQuery = value);
                          },
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by product, brand or shop...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: kPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter chips with counts
                  ValueListenableBuilder<WarrantyStatus?>(
                    valueListenable: selectedFilter,
                    builder: (context, currentFilter, _) {
                      final allCount = products.length;
                      final activeCount = products
                          .where((p) => p.status == WarrantyStatus.active)
                          .length;
                      final expiringCount = products
                          .where((p) => p.status == WarrantyStatus.expiring)
                          .length;
                      final expiredCount = products
                          .where((p) => p.status == WarrantyStatus.expired)
                          .length;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              count: allCount,
                              isSelected: currentFilter == null,
                              onTap: () => selectedFilter.value = null,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Active',
                              count: activeCount,
                              isSelected:
                                  currentFilter == WarrantyStatus.active,
                              onTap: () =>
                                  selectedFilter.value = WarrantyStatus.active,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Expiring Soon',
                              count: expiringCount,
                              isSelected:
                                  currentFilter == WarrantyStatus.expiring,
                              onTap: () => selectedFilter.value =
                                  WarrantyStatus.expiring,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Expired',
                              count: expiredCount,
                              isSelected:
                                  currentFilter == WarrantyStatus.expired,
                              onTap: () =>
                                  selectedFilter.value = WarrantyStatus.expired,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Product list
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
                                  return ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      96,
                                    ),
                                    children: [
                                      ...filteredForDisplay.map((product) {
                                        final isExpanded =
                                            expandedId == product.id;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Dismissible(
                                            key: ValueKey(product.id),
                                            direction:
                                                DismissDirection.endToStart,
                                            background: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      12,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      12,
                                                    ),
                                                  ),
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                  right: 16,
                                                ),
                                                color: const Color(0xFFFEE2E2),
                                                child: HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedDelete02,
                                                  color: const Color(
                                                    0xFFDC2626,
                                                  ),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            onDismissed: (direction) {
                                              _deleteProduct(product);
                                            },
                                            child: ProductCard(
                                              key: ValueKey(product.id),
                                              product: product,
                                              isExpanded: isExpanded,
                                              onExpand: () =>
                                                  _handleExpandProduct(product),
                                              onViewDetails: () =>
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ProductDetailScreen(
                                                            initial: product,
                                                          ),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : kInk,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : kInk,
            ),
          ),
        ],
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

/// Custom snackbar content with countdown timer for delete undo.
class _DeleteSnackBarContent extends StatefulWidget {
  const _DeleteSnackBarContent({
    required this.productName,
    required this.onUndo,
  });

  final String productName;
  final VoidCallback onUndo;

  @override
  State<_DeleteSnackBarContent> createState() => _DeleteSnackBarContentState();
}

class _DeleteSnackBarContentState extends State<_DeleteSnackBarContent> {
  late Timer _timer;
  int _secondsRemaining = 5;
  bool _undoClicked = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });
      if (_secondsRemaining <= 0) {
        _timer.cancel();
      }
    });
  }

  void _handleUndo() {
    // Prevent multiple clicks - return immediately if already clicked
    if (_undoClicked) return;

    _undoClicked = true; // Set flag first to block any further clicks
    _timer.cancel();

    setState(() {});

    widget.onUndo();

    // Show success message and dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('✓ Restored. Thank you!'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 6,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            '${widget.productName} deleted',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(
          height: 28,
          child: TextButton(
            onPressed: _undoClicked ? null : _handleUndo,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Undo (${_secondsRemaining}s)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: _undoClicked ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
