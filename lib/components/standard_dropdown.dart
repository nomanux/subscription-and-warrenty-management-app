import 'package:flutter/material.dart';

import '../theme.dart';

/// Standard dropdown with Material Design 3 styling, green borders, and custom menu.
class StandardDropdown<T> extends StatefulWidget {
  const StandardDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;

  @override
  State<StandardDropdown<T>> createState() => _StandardDropdownState<T>();
}

class _StandardDropdownState<T> extends State<StandardDropdown<T>> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final displayText = widget.items
        .firstWhere((item) => item.value == widget.value,
            orElse: () => DropdownMenuItem(
                value: widget.value,
                child: Text(widget.value.toString())))
        .child;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _showCustomMenu(context, displayText),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isHovering ? kPrimary : const Color(0xFFCBD5E1),
              width: _isHovering ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: kInk,
                    fontWeight: FontWeight.w500,
                  ),
                  child: displayText,
                ),
              ),
              const Icon(Icons.expand_more, color: kPrimary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomMenu(BuildContext context, Widget displayText) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final pos = box.localToGlobal(Offset.zero);
    final menuItems = widget.items
        .map((item) {
          final isSelected = item.value == widget.value;
          return PopupMenuItem<T>(
            value: item.value,
            height: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isSelected ? kPrimary.withValues(alpha: 0.12) : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? kPrimary : kInk,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      child: item.child,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: kPrimary, size: 18),
                ],
              ),
            ),
          );
        })
        .toList();

    showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy + box.size.height + 8,
        pos.dx + box.size.width,
        0,
      ),
      items: menuItems,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: kPrimary.withValues(alpha: 0.3), width: 1),
      ),
      color: Colors.white,
    ).then((value) {
      if (value != null) {
        widget.onChanged(value);
      }
    });
  }
}
