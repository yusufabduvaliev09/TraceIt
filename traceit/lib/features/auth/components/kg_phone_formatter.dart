import 'package:flutter/services.dart';

class KgPhoneFormatter extends TextInputFormatter {
  static const String prefix = '+996';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('996')) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    final buffer = StringBuffer(prefix);
    if (digits.isNotEmpty) {
      buffer.write(' ');
      if (digits.length <= 3) {
        buffer.write(digits);
      } else if (digits.length <= 6) {
        buffer
          ..write(digits.substring(0, 3))
          ..write(' ')
          ..write(digits.substring(3));
      } else {
        buffer
          ..write(digits.substring(0, 3))
          ..write(' ')
          ..write(digits.substring(3, 6))
          ..write(' ')
          ..write(digits.substring(6));
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
