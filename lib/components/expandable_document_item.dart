import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';
import '../widgets/receipt_image.dart';

/// Document item with add button and image preview.
class ExpandableDocumentItem extends StatelessWidget {
  const ExpandableDocumentItem({
    super.key,
    required this.title,
    required this.onAdd,
    required this.hasImage,
    this.imageUri,
  });

  final String title;
  final VoidCallback onAdd;
  final bool hasImage;
  final String? imageUri;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: kInk, fontSize: 14),
                    ),
                    const Spacer(),
                    if (hasImage)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Added',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        color: kPrimary,
                        size: 20,
                      ),
                  ],
                ),
                if (hasImage && imageUri != null && imageUri!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ReceiptImage(
                    uri: imageUri!,
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
