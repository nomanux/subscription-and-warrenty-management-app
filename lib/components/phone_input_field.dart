import 'package:flutter/material.dart';

import '../theme.dart';

/// Phone input field with fixed +88 country code prefix.
class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '01XXXX XXX XXXX',
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Extract phone number without +88 prefix
    String initialValue = widget.controller.text;
    if (initialValue.startsWith('+88')) {
      _phoneController = TextEditingController(
        text: initialValue.substring(3),
      );
    } else {
      _phoneController = TextEditingController(text: initialValue);
    }

    // Listen to phone controller changes and update main controller
    _phoneController.addListener(_updateMainController);
  }

  void _updateMainController() {
    final phoneNumber = _phoneController.text;
    if (phoneNumber.isEmpty) {
      widget.controller.text = '+88';
    } else {
      widget.controller.text = '+88$phoneNumber';
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateMainController);
    _phoneController.dispose();
    super.dispose();
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Prefix +88
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: const Text(
                  '+88',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kInk,
                  ),
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFE2E8F0),
              ),
              // Phone input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: kInk,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
