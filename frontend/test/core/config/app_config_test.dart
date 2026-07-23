import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/config/app_config.dart';

void main() {
  group('AppConfig - valeurs par défaut (sans --dart-define)', () {
    test('environment vaut "local" par défaut', () {
      expect(AppConfig.environment, 'local');
    });

    test('isLocal est vrai par défaut', () {
      expect(AppConfig.isLocal, isTrue);
      expect(AppConfig.isStaging, isFalse);
      expect(AppConfig.isProduction, isFalse);
    });

    test('apiBaseUrl est vide par défaut', () {
      expect(AppConfig.apiBaseUrl, isEmpty);
    });

    test(
      'validate() lève une StateError explicite quand API_BASE_URL est absente',
      () {
        expect(
          AppConfig.validate,
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('API_BASE_URL est absente'),
            ),
          ),
        );
      },
    );
  });
}
