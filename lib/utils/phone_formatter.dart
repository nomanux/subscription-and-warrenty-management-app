library;

/// Formats phone numbers to Bangladeshi format.
/// Input: 01XXXXXXXXXX or +880XXXXXXXXXX or any digits
/// Output: 01X XXXX XXXX

String formatBdPhoneNumber(String phoneNumber) {
  if (phoneNumber.isEmpty) return '';

  // Remove all non-digit characters
  String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Remove leading +880 and convert to 01X format
  if (cleaned.startsWith('880')) {
    cleaned = '0${cleaned.substring(3)}';
  }

  // Ensure it starts with 0
  if (!cleaned.startsWith('0')) {
    cleaned = '0$cleaned';
  }

  // Take only the first 11 digits
  if (cleaned.length > 11) {
    cleaned = cleaned.substring(0, 11);
  }

  // Pad with zeros if less than 11 digits
  if (cleaned.length < 11) {
    return cleaned;
  }

  // Format as: 01X XXXX XXXX
  return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
}
