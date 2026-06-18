import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

/// Action button for photo upload (camera/gallery).
class PhotoActionButton extends StatefulWidget {
  const PhotoActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isOutlined,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final String label;
  final bool isOutlined;
  final VoidCallback onPressed;

  @override
  State<PhotoActionButton> createState() => _PhotoActionButtonState();
}

class _PhotoActionButtonState extends State<PhotoActionButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isOutlined) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _isHovering
                    ? kPrimary.withValues(alpha: 0.05)
                    : Colors.transparent,
                border: Border.all(
                  color: _isHovering ? kPrimary : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(icon: widget.icon, color: kPrimary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: kPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: _isHovering
                      ? kPrimary.withValues(alpha: 0.9)
                      : kPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(icon: widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
