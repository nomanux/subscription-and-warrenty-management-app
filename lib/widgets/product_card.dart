library;

import 'package:flutter/material.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../theme.dart';
import '../utils/warranty.dart';

String _rgbaClass(String prop, Color color, double opacity) {
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  return '$prop-[rgba($r,$g,$b,$opacity)]';
}

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

  double get _remainingFraction {
    try {
      final total = DateTime.parse(
        widget.product.expiryDate,
      ).difference(DateTime.parse(widget.product.purchaseDate)).inDays;
      if (total <= 0) return 0;
      final remaining = daysRemaining(widget.product.expiryDate);
      return (remaining / total).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final days = daysRemaining(product.expiryDate);
    final color = kStatusColors[product.status]!;
    final pillLabel = formatWarrantyDuration(days);
    final subtitle = product.brand != null && product.brand!.isNotEmpty
        ? '${product.brand} · ${product.category}'
        : product.category;
    final thumb = product.receipt?.thumbnailUri ?? product.receipt?.uri;
    final hasImage = thumb != null && thumb.isNotEmpty;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onExpand,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: _animationCurve,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: widget.isExpanded
                ? Border.all(color: kPrimary.withValues(alpha: 0.5), width: 1)
                : Border.all(color: Colors.transparent, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: WRow(
                  children: [
                    Stack(
                      children: [
                        WContainer(
                          className:
                              '${_rgbaClass('bg', kPrimary, 0.10)} rounded-[14px]',
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
                          WText(
                            subtitle,
                            color: kMuted,
                            fontSize: 13,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        _ProgressBar(
                          fraction: _remainingFraction,
                          color: color,
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
}

class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({required this.product, required this.onViewDetails});

  final Product product;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: WColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
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
        Expanded(child: WText(value, color: kInk, fontSize: 13)),
      ],
    );
  }
}
