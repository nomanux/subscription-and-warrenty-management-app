import 'package:flutter/material.dart';

import '../theme.dart';

/// Field label for form inputs.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kInk,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A labelled, comfortably-sized text field with slate border styling.
class FormField extends StatelessWidget {
  const FormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.isRequired = false,
    this.hasError = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isRequired;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FieldLabel(label),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFDC2626), fontSize: 14),
              ),
          ],
        ),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: kInk),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              filled: true,
              fillColor: hasError ? const Color(0xFFFEE2E2) : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? const Color(0xFFDC2626) : kPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'This field is required',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
              ),
            ),
          )
        else
          const SizedBox(height: 14),
      ],
    );
  }
}
