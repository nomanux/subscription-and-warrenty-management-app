import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme.dart';

/// Category pill/chip with horizontal design - default gray, selected green.
class CategoryPill extends StatefulWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<CategoryPill> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: widget.selected ? kPrimary : const Color(0xFFF5F5F5),
          border: Border.all(
            color: widget.selected ? kPrimary : const Color(0xFFE5E7EB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: widget.icon,
              color: widget.selected ? Colors.white : const Color(0xFF5E5E5E),
              size: 18,
            ),
            const SizedBox(width: 13),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.selected ? Colors.white : const Color(0xFF5E5E5E),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
