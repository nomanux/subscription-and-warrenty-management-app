/// A single warranty card — avatar, name/category, days-left pill, and a thin
/// progress bar showing how much warranty time remains.
///
/// Built with flutter_twind for the shell; the progress bar uses plain
/// Containers for pixel precision. A trailing 3-dot menu (Edit/Delete) appears
/// only when callbacks are provided (the Warranties list); the Dashboard
/// "expiring soon" cards omit it to match the mockup.
library;

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/warranty.dart';

/// Build a Tailwind arbitrary rgba class, e.g. `bg-[rgba(22,163,74,0.12)]`.
String _rgbaClass(String prop, Color color, double opacity) {
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  return '$prop-[rgba($r,$g,$b,$opacity)]';
}

/// Pick an icon for the category (used when there's no receipt thumbnail).
List<List<dynamic>> _categoryIcon(String category) {
  switch (category) {
    case 'Electronics':
      return HugeIcons.strokeRoundedSmartPhone01;
    case 'Home Appliances':
      return HugeIcons.strokeRoundedHome01;
    case 'Kitchen Appliances':
      return HugeIcons.strokeRoundedKitchenUtensils;
    case 'Furniture':
      return HugeIcons.strokeRoundedChair01;
    case 'Vehicle':
      return HugeIcons.strokeRoundedCar01;
    default:
      return HugeIcons.strokeRoundedPackage01;
  }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.isExpanded = false,
    this.onExpand,
    this.onViewDetails,
  });

  final Product product;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final VoidCallback? onViewDetails;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Product get product => widget.product;
  VoidCallback? get onViewDetails => widget.onViewDetails;

  /// Fraction of the warranty period still remaining (0..1).
  double get _remainingFraction {
    try {
      final total = DateTime.parse(
        product.expiryDate,
      ).difference(DateTime.parse(product.purchaseDate)).inDays;
      if (total <= 0) return 0;
      final remaining = daysRemaining(product.expiryDate);
      return (remaining / total).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = daysRemaining(product.expiryDate);
    final color = kStatusColors[product.status]!;
    final expired = product.status == WarrantyStatus.expired;
    final pillLabel = expired ? 'Expired' : '$days day${days == 1 ? '' : 's'}';
    final subtitle = product.brand != null && product.brand!.isNotEmpty
        ? '${product.brand} · ${product.category}'
        : product.category;
    final thumb = product.receipt?.thumbnailUri ?? product.receipt?.uri;
    final hasImage = thumb != null && thumb.isNotEmpty;

    final collapsedContent = WRow(
      children: [
        // Avatar with image badge indicator.
        Stack(
          children: [
            // Always show category icon
            WContainer(
              className: '${_rgbaClass('bg', kPrimary, 0.10)} rounded-[14px]',
              width: 48,
              height: 48,
              child: Center(
                child: HugeIcon(
                  icon: _categoryIcon(product.category),
                  color: kPrimary,
                  size: 22,
                ),
              ),
            ),
            // Image indicator badge
            if (hasImage)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.image,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Title + subtitle.
        Expanded(
          child: WColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WText(
                product.productName,
                color: kInk,
                fontSize: 15,
                className: 'font-bold',
                maxLines: 1,
              ),
              const SizedBox(height: 3),
              WText(subtitle, color: kMuted, fontSize: 13, maxLines: 1),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Days pill + progress bar.
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pillLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ProgressBar(fraction: _remainingFraction, color: color),
          ],
        ),
      ],
    );

    final expandedDetails = WColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
        const SizedBox(height: 16),
        _DetailRow('Purchase Date', product.purchaseDate),
        const SizedBox(height: 12),
        _DetailRow('Expiry Date', product.expiryDate),
        if (product.serialNumber?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _DetailRow('Serial Number', product.serialNumber!),
        ],
        if (product.notes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          _DetailRow('Notes', product.notes!),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onViewDetails ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Details'),
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onExpand,
      child: WContainer(
        className: 'bg-white rounded-[18px] shadow-md p-4',
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                collapsedContent,
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _animation.value,
                    child: Opacity(
                      opacity: _animation.value,
                      child: expandedDetails,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction == 0 ? 0.06 : fraction,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return WRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: WText(
            label,
            color: kMuted,
            fontSize: 13,
            className: 'font-medium',
          ),
        ),
        Expanded(
          child: WText(
            value,
            color: kInk,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

