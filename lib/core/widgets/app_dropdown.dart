/// A reusable, standard dropdown for the whole app.
///
/// Renders as an input-styled field; tapping opens a rounded bottom sheet with
/// the options (the selected one highlighted + checked). Use everywhere so all
/// "select" controls look and behave the same.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.title,
  });

  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  /// Optional heading shown at the top of the picker sheet.
  final String? title;

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle.
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title!,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: kInk),
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: items.map((e) {
                    final selected = e == value;
                    return ListTile(
                      title: Text(
                        itemLabel(e),
                        style: TextStyle(
                          fontSize: 16,
                          color: selected ? kPrimary : kInk,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_rounded, color: kPrimary)
                          : null,
                      onTap: () => Navigator.pop(ctx, e),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  itemLabel(value),
                  style: const TextStyle(fontSize: 16, color: kInk),
                ),
              ),
              HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: kMuted,
                  size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
