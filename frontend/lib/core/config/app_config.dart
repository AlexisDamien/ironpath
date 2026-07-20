abstract final class AppConfig {
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isLocal => environment == 'local';

  static bool get isStaging => environment == 'staging';

  static bool get isProduction => environment == 'production';

  static void validate() {
    const allowedEnvironments = {'local', 'staging', 'production'};

    if (!allowedEnvironments.contains(environment)) {
      throw StateError(
        'APP_ENV doit valoir local, staging ou production. '
        'Valeur actuelle : "$environment".',
      );
    }

    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL est absente. '
        'Ajoute --dart-define=API_BASE_URL=... '
        'dans la configuration Flutter.',
      );
    }

    final uri = Uri.tryParse(apiBaseUrl);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError('API_BASE_URL est invalide : "$apiBaseUrl".');
    }

    if (isProduction && uri.scheme != 'https') {
      throw StateError('API_BASE_URL doit utiliser HTTPS en production.');
    }
  }
}
