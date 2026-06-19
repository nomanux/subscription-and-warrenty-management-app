/// Dashboard — coral hero header, a donut "summary" card (total + status
/// breakdown), and an "expiring soon" list. Inspired by the EGOVERN reference.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/providers/user_provider.dart';
import '../features/auth/presentation/providers/google_auth_provider.dart';
import '../features/auth/presentation/providers/user_auth_provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../utils/warranty.dart';
import '../widgets/app_drawer.dart';
import '../widgets/donut_chart.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class _Stats {
  int total = 0;
  int active = 0;
  int expiring = 0;
  int expired = 0;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? expandedProductId;
  late final Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = productService.watchProducts();
  }

  _Stats _computeStats(List<Product> products) {
    final stats = _Stats();
    for (final p in products) {
      stats.total += 1;
      switch (p.status) {
        case WarrantyStatus.active:
          stats.active += 1;
        case WarrantyStatus.expiring:
          stats.expiring += 1;
        case WarrantyStatus.expired:
          stats.expired += 1;
      }
    }
    return stats;
  }

  List<Product> _expiringSoon(List<Product> products) {
    return products.where((p) => p.status == WarrantyStatus.expiring).toList()
      ..sort(
        (a, b) =>
            daysRemaining(a.expiryDate).compareTo(daysRemaining(b.expiryDate)),
      );
  }

  void _handleExpandProduct(Product product) {
    setState(() {
      expandedProductId = expandedProductId == product.id ? null : product.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentIndex: 0, onNavigate: widget.onNavigate),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          final stats = _computeStats(products);
          final expiringSoon = _expiringSoon(products);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeroHeader(),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SummaryCard(stats: stats),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Expiring soon',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    if (expiringSoon.isNotEmpty)
                      GestureDetector(
                        onTap: () => widget.onNavigate(1),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (expiringSoon.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyExpiring(),
                )
              else
                ...expiringSoon.map((p) {
                  final isExpanded = expandedProductId == p.id;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: ProductCard(
                      key: ValueKey(p.id),
                      product: p,
                      isExpanded: isExpanded,
                      onExpand: () => _handleExpandProduct(p),
                      onViewDetails: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(initial: p),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

/// Coral gradient banner with greeting (rounded bottom corners).
class _HeroHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Get user data
    final userAuthState = ref.watch(userAuthStateProvider);
    final userAsync = ref.watch(userProvider);
    final googleAccountAsync = ref.watch(googleAccountProvider);

    // Determine display name (prioritizes Google name)
    String displayName = googleAccountAsync.when(
      data: (googleAccount) {
        // If Google logged in and has a name, use it
        if (googleAccount?.displayName != null) {
          return googleAccount!.displayName!;
        }
        // Fall back to user name from auth provider
        return userAsync.maybeWhen(
          data: (user) => user.name ?? 'User',
          orElse: () => 'User',
        );
      },
      loading: () => 'User',
      error: (_, __) => userAsync.maybeWhen(
        data: (user) => user.name ?? 'User',
        orElse: () => 'User',
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 22, 20, 44),
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
      child: Row(
        children: [
          InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMenu01,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day 👋',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hello $displayName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White summary card: donut + status breakdown.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final _Stats stats;

  int _pct(int v) => stats.total == 0 ? 0 : ((v / stats.total) * 100).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Warranty Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DonutChart(
                size: 132,
                centerValue: '${stats.total}',
                centerLabel: stats.total == 1 ? 'Warranty' : 'Warranties',
                segments: [
                  DonutSegment(
                    stats.active,
                    kStatusColors[WarrantyStatus.active]!,
                  ),
                  DonutSegment(
                    stats.expiring,
                    kStatusColors[WarrantyStatus.expiring]!,
                  ),
                  DonutSegment(
                    stats.expired,
                    kStatusColors[WarrantyStatus.expired]!,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _BreakdownRow(
                      color: kStatusColors[WarrantyStatus.active]!,
                      pct: _pct(stats.active),
                      label: 'Active',
                      count: stats.active,
                    ),
                    const SizedBox(height: 14),
                    _BreakdownRow(
                      color: kStatusColors[WarrantyStatus.expiring]!,
                      pct: _pct(stats.expiring),
                      label: 'Expiring',
                      count: stats.expiring,
                    ),
                    const SizedBox(height: 14),
                    _BreakdownRow(
                      color: kStatusColors[WarrantyStatus.expired]!,
                      pct: _pct(stats.expired),
                      label: 'Expired',
                      count: stats.expired,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.color,
    required this.pct,
    required this.label,
    required this.count,
  });

  final Color color;
  final int pct;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  height: 1.1,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
            ],
          ),
        ),
        Text(
          '$count ${count == 1 ? 'item' : 'items'}',
          style: const TextStyle(
            fontSize: 12,
            color: kMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyExpiring extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      child: const Column(
        children: [
          Text('🎉', style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            'Nothing expiring in the next 30 days.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
