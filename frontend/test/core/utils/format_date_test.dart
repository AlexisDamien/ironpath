import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/format_date.dart';

void main() {
  group('formatDate', () {
    test('formate une date en jj/mm/aaaa', () {
      expect(formatDate(DateTime(2026, 7, 3)), '03/07/2026');
    });
  });

  group('formatApiDate', () {
    test('utilise le fallback pour null ou une chaîne vide', () {
      expect(formatApiDate(null), 'Non renseigné');
      expect(formatApiDate('   ', fallback: '-'), '-');
    });

    test('formate une date ISO valide', () {
      expect(formatApiDate('2026-07-20'), '20/07/2026');
    });

    test('conserve une valeur non parseable', () {
      expect(formatApiDate('été 2026'), 'été 2026');
    });
  });

  test('formatDateForApi retourne aaaa-mm-jj', () {
    expect(formatDateForApi(DateTime(2026, 1, 9)), '2026-01-09');
  });
}
