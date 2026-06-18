import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

/// Date picker field with Material Design 3 styling.
class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  bool _isFocused = false;

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final initial = widget.controller.text.isNotEmpty
        ? DateTime.tryParse(widget.controller.text)
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked != null) {
      final iso = picked.toIso8601String().substring(0, 10);
      widget.controller.text = iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: kInk,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: _pickDate,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isFocused = true),
            onExit: (_) => setState(() => _isFocused = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _isFocused ? kPrimary : const Color(0xFFCBD5E1),
                  width: _isFocused ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: kMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.controller.text.isEmpty
                          ? widget.hint ?? 'Select date'
                          : DateFormat('d MMM, yyyy')
                              .format(DateTime.parse(widget.controller.text)),
                      style: TextStyle(
                        color: widget.controller.text.isEmpty ? kMuted : kInk,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: kMuted, size: 14),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
