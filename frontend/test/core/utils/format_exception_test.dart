import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/core/utils/format_exception.dart';

DioException dioError({
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: data == null
        ? null
        : Response<dynamic>(
            requestOptions: options,
            statusCode: 400,
            data: data,
          ),
  );
}

void main() {
  test('préfère la clé error du backend', () {
    expect(
      formatExceptionMessage(dioError(data: {'error': 'Email invalide'})),
      'Email invalide',
    );
  });

  test('utilise la clé message si error est absente', () {
    expect(
      formatExceptionMessage(dioError(data: {'message': 'Accès refusé'})),
      'Accès refusé',
    );
  });

  test('traduit les erreurs de connexion', () {
    expect(
      formatExceptionMessage(
        dioError(type: DioExceptionType.connectionTimeout),
      ),
      'Impossible de contacter le serveur',
    );
    expect(
      formatExceptionMessage(
        dioError(type: DioExceptionType.receiveTimeout),
      ),
      'Impossible de contacter le serveur',
    );
    expect(
      formatExceptionMessage(
        dioError(type: DioExceptionType.connectionError),
      ),
      'Impossible de contacter le serveur',
    );
  });

  test('retire le préfixe Exception', () {
    expect(formatExceptionMessage(Exception('Erreur métier')), 'Erreur métier');
  });

  test('utilise le fallback pour un message vide', () {
    expect(
      formatExceptionMessage(const _EmptyError(), fallback: 'Erreur'),
      'Erreur',
    );
  });
}

class _EmptyError {
  const _EmptyError();

  @override
  String toString() => '';
}
