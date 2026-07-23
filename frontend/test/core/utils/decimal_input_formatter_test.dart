import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/decimal_input_formatter.dart';

void main() {
  late DecimalInputFormatter formatter;

  setUp(() {
    formatter = DecimalInputFormatter(decimalDigits: 2);
  });

  TextEditingValue value(String text) => TextEditingValue(
      text: text, selection: TextSelection.collapsed(offset: text.length));

  test('accepte un entier sans décimale', () {
    final result = formatter.formatEditUpdate(value(''), value('80'));
    expect(result.text, '80');
  });

  test('accepte jusqu\'à 2 décimales', () {
    final result = formatter.formatEditUpdate(value('80.5'), value('80.55'));
    expect(result.text, '80.55');
  });

  test('rejette une 3e décimale', () {
    final oldVal = value('80.55');
    final result = formatter.formatEditUpdate(oldVal, value('80.555'));
    expect(result.text, '80.55');
  });

  test('accepte la virgule comme séparateur', () {
    final result = formatter.formatEditUpdate(value('80'), value('80,5'));
    expect(result.text, '80,5');
  });

  test('accepte un champ vide (effacement)', () {
    final result = formatter.formatEditUpdate(value('80'), value(''));
    expect(result.text, '');
  });

  test('rejette un second séparateur décimal', () {
    final oldVal = value('80.5');
    final result = formatter.formatEditUpdate(oldVal, value('80.5.'));
    expect(result.text, '80.5');
  });
}
