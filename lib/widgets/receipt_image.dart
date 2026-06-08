/// Renders a receipt image from a stored URI.
///
/// Receipts are stored as base64 data URIs (e.g. "data:image/png;base64,...")
/// to match the old app, but this also handles network URLs and local file
/// paths so older/newer records both display.
library;

import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ReceiptImage extends StatelessWidget {
  const ReceiptImage({
    super.key,
    required this.uri,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String uri;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _buildImage() {
    if (uri.startsWith('data:')) {
      final commaIndex = uri.indexOf(',');
      final base64Part = commaIndex >= 0 ? uri.substring(commaIndex + 1) : '';
      try {
        final bytes = base64Decode(base64Part);
        return Image.memory(bytes, width: width, height: height, fit: fit);
      } catch (_) {
        return _placeholder();
      }
    }
    if (uri.startsWith('http')) {
      return Image.network(uri, width: width, height: height, fit: fit);
    }
    if (!kIsWeb && uri.isNotEmpty) {
      return Image.file(File(uri), width: width, height: height, fit: fit);
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.receipt_long, color: Color(0xFF9CA3AF)),
      );
}
