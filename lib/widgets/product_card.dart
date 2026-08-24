library;

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/warranty.dart';
import './receipt_image.dart';

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

String _formatDate(String iso) {
  try {
    final date = DateTime.parse(iso).toLocal();
    return DateFormat('d MMM, yy').format(date);
  } catch (_) {
    return iso;
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

class _ProductCardState extends State<ProductCard> {
  static const _animationDuration = Duration(milliseconds: 260);
  static const _animationCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final days = daysRemaining(product.expiryDate);
    final color = kStatusColors[product.status]!;
    final statusLabel = product.status == WarrantyStatus.active
        ? 'Active'
        : product.status == WarrantyStatus.expiring
        ? 'Expiring Soon'
        : 'Expired';
    final daysText = _formatDaysRemaining(days);
    final expiryDate = _formatDate(product.expiryDate);
    final subtitle = product.brand != null && product.brand!.isNotEmpty
        ? '${product.category} • ${product.brand}'
        : product.category;
    final thumb = product.productImage?.uri ?? product.receipt?.thumbnailUri ?? product.receipt?.uri;
    final hasImage = thumb != null && thumb.isNotEmpty;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onExpand,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: _animationCurve,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: widget.isExpanded
                ? Border.all(color: kPrimary.withValues(alpha: 0.5), width: 1)
                : Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product icon
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: _categoryIcon(product.category),
                              color: kPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                        if (hasImage)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
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
                    const SizedBox(width: 12),
                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kInk,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.shopName?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront,
                                  size: 12,
                                  color: kMuted,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    product.shopName!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: kMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (product.coverages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: product.coverages
                                    .map((coverage) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kPrimary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            coverage.type,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: kPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right side: status, time, expiry
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          daysText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Expires on $expiryDate',
                          style: const TextStyle(
                            fontSize: 9,
                            color: kMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _ExpandedDetails(
                  product: product,
                  onViewDetails: widget.onViewDetails,
                ),
                crossFadeState: widget.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: _animationDuration,
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeIn,
                sizeCurve: _animationCurve,
                alignment: Alignment.topCenter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDaysRemaining(int days) => formatWarrantyDuration(days);
}

class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({required this.product, required this.onViewDetails});

  final Product product;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final hasProductImage = product.productImage?.uri != null && product.productImage!.uri.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: WColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          if (hasProductImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ReceiptImage(
                uri: product.productImage!.uri,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _DetailRow('Purchase Date', _formatDate(product.purchaseDate)),
          const SizedBox(height: 12),
          _DetailRow('Expiry Date', _formatDate(product.expiryDate)),
          if (product.shopName?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _DetailRow('Shop Name', product.shopName!),
          ],
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
                backgroundColor: kPrimary.withValues(alpha: 0.1),
                foregroundColor: kPrimary,
                elevation: 0,
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
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
        Expanded(child: WText(value, color: kInk, fontSize: 13)),
      ],
    );
  }
}
