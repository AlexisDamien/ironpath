import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/core/network/api_client.dart';

import '../../helpers/mocks.dart';
import '../../helpers/recording_http_adapter.dart';

void main() {
  late MockTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.getAccessToken())
        .thenAnswer((_) async => 'access-token');
    when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  });

  test('ajoute le Bearer token aux routes privées', () async {
    final client = ApiClient(tokenStorage: tokenStorage);
    client.dio.options.baseUrl = 'https://example.test';
    final adapter = RecordingHttpClientAdapter(
      const [
        StubHttpResponse(data: {'ok': true})
      ],
    );
    client.dio.httpClientAdapter = adapter;

    await client.get('/api/profile');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer access-token',
    );
    verify(() => tokenStorage.getAccessToken()).called(1);
  });

  test('n’ajoute pas de token aux routes publiques d’authentification',
      () async {
    final client = ApiClient(tokenStorage: tokenStorage);
    client.dio.options.baseUrl = 'https://example.test';
    final adapter = RecordingHttpClientAdapter(
      const [
        StubHttpResponse(data: {'token': 'x'})
      ],
    );
    client.dio.httpClientAdapter = adapter;

    await client.post('/api/auth/login', data: {
      'email': 'alex@example.com',
      'password': 'secret',
    });

    expect(adapter.requests.single.headers['Authorization'], isNull);
    verifyNever(() => tokenStorage.getAccessToken());
  });

  test('efface les tokens après un 401 sans refresh token', () async {
    final client = ApiClient(tokenStorage: tokenStorage);
    client.dio.options.baseUrl = 'https://example.test';
    client.dio.httpClientAdapter = RecordingHttpClientAdapter(
      const [
        StubHttpResponse(statusCode: 401, data: {'error': 'expired'})
      ],
    );

    await expectLater(
      client.get('/api/profile'),
      throwsA(isA<DioException>()),
    );

    verify(() => tokenStorage.getRefreshToken()).called(1);
    verify(() => tokenStorage.clearTokens()).called(1);
  });
}
