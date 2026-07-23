import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final pattern =
        RegExp(r'^\d*[.,]?\d{0,' + decimalDigits.toString() + r'}$');
    if (pattern.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

final List<TextInputFormatter> twoDecimalInputFormatters = [
  DecimalInputFormatter(decimalDigits: 2),
];
