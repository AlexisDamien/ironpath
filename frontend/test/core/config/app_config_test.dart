import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/config/app_config.dart';

// NOTE : `AppConfig.environment` et `AppConfig.apiBaseUrl` sont des
// `String.fromEnvironment`, donc résolus à la COMPILATION (--dart-define),
// pas à l'exécution. Ce fichier de test tourne sans define particulier,
// donc seul le comportement par défaut (API_BASE_URL absente, APP_ENV=local)
// est vérifiable ici. Les branches "URL invalide" et "HTTPS obligatoire en
// production" nécessiteraient un binaire de test compilé séparément avec
// --dart-define=API_BASE_URL=... et ne sont donc pas couvertes par ce fichier.
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
