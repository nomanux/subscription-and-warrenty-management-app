/// Read-only warranty detail page. The Edit action (pencil) opens the
/// full-page editable form (where the item can also be deleted). Listens to
/// the live stream so it reflects edits and pops itself if the item is deleted.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../utils/warranty.dart';
import '../widgets/product_form.dart';
import '../widgets/receipt_image.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.initial});

  final Product initial;

  String _fmt(String iso) {
    try {
      return DateFormat('d MMM, yy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: productService.watchProducts(),
      builder: (context, snapshot) {
        Product product = initial;
        if (snapshot.hasData) {
          final match =
              snapshot.data!.where((p) => p.id == initial.id).toList();
          if (match.isEmpty) {
            // Deleted elsewhere — close this page.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            });
          } else {
            product = match.first;
          }
        }

        final color = kStatusColors[product.status]!;
        final days = daysRemaining(product.expiryDate);
        final statusLabel = product.status == WarrantyStatus.expired
            ? 'Expired'
            : '$days day${days == 1 ? '' : 's'} left';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Warranty Details'),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: kInk,
                    size: 22),
                onPressed: () => showProductForm(context, initial: product),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimary, kPrimaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.productName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(product.category,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Product Photo section
              if (product.productImage?.uri != null && product.productImage!.uri.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: kCardShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ReceiptImage(
                      uri: product.productImage!.uri,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Info card.
              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: kCardShadow,
                ),
                child: Column(
                  children: [
                    if (product.brand != null && product.brand!.isNotEmpty)
                      _InfoRow(
                          icon: HugeIcons.strokeRoundedTag01,
                          label: 'Brand',
                          value: product.brand!),
                    _InfoRow(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        label: 'Purchase date',
                        value: _fmt(product.purchaseDate)),
                    _InfoRow(
                        icon: HugeIcons.strokeRoundedClock01,
                        label: 'Warranty period',
                        value: '${product.warrantyDurationMonths} months'),
                    _InfoRow(
                        icon: HugeIcons.strokeRoundedShield01,
                        label: 'Expires',
                        value: _fmt(product.expiryDate)),
                    if (product.location != null &&
                        product.location!.isNotEmpty)
                      _InfoRow(
                          icon: HugeIcons.strokeRoundedMapPin,
                          label: 'Location',
                          value: product.location!),
                    if (product.serialNumber != null &&
                        product.serialNumber!.isNotEmpty)
                      _InfoRow(
                          icon: HugeIcons.strokeRoundedBarCode01,
                          label: 'Serial number',
                          value: product.serialNumber!),
                    if (product.notes != null && product.notes!.isNotEmpty)
                      _InfoRow(
                          icon: HugeIcons.strokeRoundedNote,
                          label: 'Notes',
                          value: product.notes!,
                          last: true),
                  ],
                ),
              ),
              // Shop Information section
              if (product.shopName != null && product.shopName!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Shop Information',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kInk)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Name
                      Row(
                        children: [
                          const Icon(Icons.store, color: kPrimary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Shop Name',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: kMuted,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(product.shopName ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: kInk,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Shop Phone Number with call button
                      if (product.shopPhoneNumber != null &&
                          product.shopPhoneNumber!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: kPrimary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Phone Number',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: kMuted,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(product.shopPhoneNumber ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: kInk,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCall,
                                color: kPrimary,
                                size: 22,
                              ),
                              onPressed: () async {
                                final phoneNumber = product.shopPhoneNumber;
                                if (phoneNumber != null &&
                                    phoneNumber.isNotEmpty) {
                                  final uri =
                                      Uri(scheme: 'tel', path: phoneNumber);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                }
                              },
                              tooltip: 'Call shop',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              // Product Photo section
              if (product.productImage?.uri != null && product.productImage!.uri.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Product Photo',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kInk)),
                const SizedBox(height: 10),
                ReceiptImage(
                  uri: product.productImage!.uri,
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
              // Receipt section - always show
              const SizedBox(height: 20),
              const Text('Receipt',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              const SizedBox(height: 10),
              // Show image if available, otherwise show "No image available"
              if (product.receipt?.uri != null && product.receipt!.uri.isNotEmpty)
                ReceiptImage(
                  uri: product.receipt!.uri,
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(16),
                )
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Receipt Image',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Warranty Card section
              const SizedBox(height: 24),
              const Text('Warranty Card',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              const SizedBox(height: 10),
              if (product.warrantyCard?.uri != null && product.warrantyCard!.uri.isNotEmpty)
                ReceiptImage(
                  uri: product.warrantyCard!.uri,
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(16),
                )
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Warranty Card',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Visiting Card section
              const SizedBox(height: 24),
              const Text('Visiting Card',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kInk)),
              const SizedBox(height: 10),
              if (product.visitingCard?.uri != null && product.visitingCard!.uri.isNotEmpty)
                ReceiptImage(
                  uri: product.visitingCard!.uri,
                  width: double.infinity,
                  height: 220,
                  borderRadius: BorderRadius.circular(16),
                )
              else
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.contact_mail,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Visiting Card',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFEFF1F5), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, color: kPrimary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: kMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: kInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
