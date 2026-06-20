import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits =
        newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('56')) {
      digits = digits.substring(2);
    }

    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    String result = '+56';

    if (digits.isNotEmpty) {
      result += ' ${digits[0]}';
    }

    if (digits.length > 1) {
      result +=
          ' ${digits.substring(1, digits.length.clamp(1, 5))}';
    }

    if (digits.length > 5) {
      result +=
          ' ${digits.substring(5, digits.length)}';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(
        offset: result.length,
      ),
    );
  }
}