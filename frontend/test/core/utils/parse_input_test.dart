import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/parse_input.dart';

void main() {
  test('parseNullableText normalise les espaces', () {
    expect(parseNullableText('  note  '), 'note');
    expect(parseNullableText('   '), isNull);
  });

  test('parseDecimal accepte le point et la virgule', () {
    expect(parseDecimal('12.5'), 12.5);
    expect(parseDecimal(' 12,5 '), 12.5);
    expect(parseDecimal('abc'), isNull);
  });
}
