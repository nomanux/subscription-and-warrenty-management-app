import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';
import '../widgets/receipt_image.dart';
import 'photo_action_button.dart';

/// Product photo section with camera and gallery options - Material Design 3.
class ProductPhotoSection extends StatefulWidget {
  const ProductPhotoSection({
    super.key,
    required this.imageUri,
    required this.onCamera,
    required this.onGallery,
  });

  final String? imageUri;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  State<ProductPhotoSection> createState() => _ProductPhotoSectionState();
}

class _ProductPhotoSectionState extends State<ProductPhotoSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUri == null || widget.imageUri!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedImage02,
                  color: kPrimary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add Product Photo',
              style: TextStyle(
                color: kInk,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap camera or select from gallery',
              style: TextStyle(
                color: kMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PhotoActionButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    label: 'Camera',
                    isOutlined: false,
                    onPressed: widget.onCamera,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PhotoActionButton(
                    icon: HugeIcons.strokeRoundedImage02,
                    label: 'Gallery',
                    isOutlined: true,
                    onPressed: widget.onGallery,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              ReceiptImage(
                uri: widget.imageUri!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: PhotoActionButton(
                        icon: HugeIcons.strokeRoundedRefresh,
                        label: 'Retake',
                        isOutlined: true,
                        onPressed: widget.onCamera,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PhotoActionButton(
                        icon: HugeIcons.strokeRoundedPencilEdit02,
                        label: 'Change',
                        isOutlined: true,
                        onPressed: widget.onGallery,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
