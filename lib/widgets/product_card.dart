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
import 'receipt_image.dart';

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

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;

  /// Tapping the card (e.g. to open the detail page).
  final VoidCallback? onTap;

  /// Fraction of the warranty period still remaining (0..1).
  double get _remainingFraction {
    try {
      final total = DateTime.parse(product.expiryDate)
          .difference(DateTime.parse(product.purchaseDate))
          .inDays;
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
    final pillLabel =
        expired ? 'Expired' : '$days day${days == 1 ? '' : 's'}';
    final subtitle = product.brand != null && product.brand!.isNotEmpty
        ? '${product.brand} · ${product.category}'
        : product.category;
    final thumb = product.receipt?.thumbnailUri ?? product.receipt?.uri;

    final card = WContainer(
      className: 'bg-white rounded-[18px] shadow-md p-4',
      child: WRow(
        children: [
          // Avatar.
          if (thumb != null && thumb.isNotEmpty)
            ReceiptImage(
              uri: thumb,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(14),
            )
          else
            WContainer(
              className: '${_rgbaClass('bg', kPrimary, 0.10)} rounded-[14px]',
              width: 48,
              height: 48,
              child: Center(
                child: HugeIcon(
                    icon: _categoryIcon(product.category),
                    color: kPrimary,
                    size: 22),
              ),
            ),
          const SizedBox(width: 14),
          // Title + subtitle.
          Expanded(
            child: WColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WText(product.productName,
                    color: kInk,
                    fontSize: 15,
                    className: 'font-bold',
                    maxLines: 1),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
    );

    // Whole card is tappable (opens the detail page).
    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: card,
      );
    }
    return card;
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
