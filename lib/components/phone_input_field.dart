import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Phone input field with fixed +88 country code prefix - Material Design 3.
/// Enforces Bangladesh phone format: 01X XXXX XXXX (11 digits max).
class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '01XXXX XXX XXXX',
    this.hasError = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool hasError;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _phoneController;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    // Extract phone number without +88 prefix
    String initialValue = widget.controller.text;
    if (initialValue.startsWith('+88')) {
      _phoneController = TextEditingController(
        text: _extractDigitsOnly(initialValue.substring(3)),
      );
    } else {
      _phoneController = TextEditingController(
        text: _extractDigitsOnly(initialValue),
      );
    }

    // Listen to phone controller changes and update main controller
    _phoneController.addListener(_updateMainController);
  }

  String _extractDigitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return '';
    // Take only first 11 digits
    digits = digits.substring(0, digits.length > 11 ? 11 : digits.length);
    // Format as: 01X XXXX XXXX
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 7) {
      return '${digits.substring(0, 3)} ${digits.substring(3)}';
    } else {
      return '${digits.substring(0, 3)} ${digits.substring(3, 7)} ${digits.substring(7)}';
    }
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _updateMainController() {
    final phoneDigits = _extractDigitsOnly(_phoneController.text);
    if (phoneDigits.isEmpty) {
      widget.controller.text = '';
    } else {
      widget.controller.text = '+88$phoneDigits';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _phoneController.removeListener(_updateMainController);
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: kInk,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.hasError)
              const Text(
                ' (Invalid format)',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: widget.hasError ? const Color(0xFFFEE2E2) : Colors.white,
              border: Border.all(
                color: widget.hasError
                    ? const Color(0xFFDC2626)
                    : (_isFocused ? kPrimary : const Color(0xFFCBD5E1)),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Prefix +88
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Text(
                    '+88',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kInk,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 20,
                  color: const Color(0xFFE5E7EB),
                ),
                // Phone input
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    onChanged: (value) {
                      final digits = _extractDigitsOnly(value);
                      if (digits.length <= 11) {
                        final formatted = _formatPhoneNumber(digits);
                        if (formatted != _phoneController.text) {
                          _phoneController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: kInk,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    cursorColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.hasError && _phoneController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Bangladesh phone number must be 11 digits (01X XXXX XXXX)',
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
