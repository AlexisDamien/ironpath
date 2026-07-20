import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/format_duration.dart';

void main() {
  group('formatClockDuration', () {
    test('formate les minutes et secondes', () {
      expect(formatClockDuration(0), '00:00');
      expect(formatClockDuration(65), '01:05');
      expect(formatClockDuration(3601), '60:01');
    });

    test('ramène une durée négative à zéro', () {
      expect(formatClockDuration(-12), '00:00');
    });
  });

  group('formatRestDuration', () {
    test('retourne un tiret pour null', () {
      expect(formatRestDuration(null), '-');
    });

    test('formate seulement les secondes sous une minute', () {
      expect(formatRestDuration(45), '45s');
    });

    test('formate minutes et secondes', () {
      expect(formatRestDuration(90), '1min30s');
      expect(formatRestDuration(120), '2min00s');
    });
  });
}
