import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/identity/data/repository_identity.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/recording_http_adapter.dart';

void main() {
  late Dio dio;
  late RecordingHttpClientAdapter adapter;
  late MockTokenStorage tokenStorage;
  late RepositoryIdentity repository;

  void configure(List<StubHttpResponse> responses) {
    adapter = RecordingHttpClientAdapter(responses);
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = adapter;
    tokenStorage = MockTokenStorage();
    repository = RepositoryIdentity(dio: dio, tokenStorage: tokenStorage);

    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
        persist: any(named: 'persist'),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});
  }

  test('register envoie les consentements et sauvegarde les tokens', () async {
    configure([
      const StubHttpResponse(data: {
        'token': 'access',
        'refreshToken': 'refresh',
        'emailVerified': false,
      }),
    ]);

    final verified = await repository.register(
      email: 'alex@example.com',
      password: 'MotDePasse12!',
      rgpdConsent: true,
    );

    expect(verified, isFalse);
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/api/auth/register');
    expect(adapter.requests.single.data, {
      'email': 'alex@example.com',
      'password': 'MotDePasse12!',
      'rgpdConsent': true,
    });
    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        persist: true,
      ),
    ).called(1);
  });

  test('login respecte le choix Se souvenir de moi', () async {
    configure([
      const StubHttpResponse(data: {
        'token': 'access',
        'refreshToken': 'refresh',
        'emailVerified': true,
      }),
    ]);

    final verified = await repository.login(
      email: 'alex@example.com',
      password: 'MotDePasse12!',
      rememberMe: false,
    );

    expect(verified, isTrue);
    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        persist: false,
      ),
    ).called(1);
  });

  test('restoreSession retourne null si la restauration est désactivée',
      () async {
    configure([]);
    when(() => tokenStorage.shouldRestoreSession())
        .thenAnswer((_) async => false);

    expect(await repository.restoreSession(), isNull);
    expect(adapter.requests, isEmpty);
  });

  test('restoreSession retourne null sans token', () async {
    configure([]);
    when(() => tokenStorage.shouldRestoreSession())
        .thenAnswer((_) async => true);
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
    when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isNull);
  });

  test('restoreSession vérifie le statut email quand un token existe',
      () async {
    configure([
      const StubHttpResponse(data: {'emailVerified': true}),
    ]);
    when(() => tokenStorage.shouldRestoreSession())
        .thenAnswer((_) async => true);
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => 'access');
    when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isTrue);
    expect(
      adapter.requests.single.path,
      '/api/auth/email-verification-status',
    );
  });

  test('restoreSession efface les tokens si la vérification échoue', () async {
    configure([
      const StubHttpResponse(statusCode: 500, data: {'error': 'boom'}),
    ]);
    when(() => tokenStorage.shouldRestoreSession())
        .thenAnswer((_) async => true);
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => 'access');
    when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isNull);
    verify(() => tokenStorage.clearTokens()).called(1);
  });

  test('logout efface toujours les tokens, même si le serveur échoue',
      () async {
    configure([
      const StubHttpResponse(statusCode: 500, data: {'error': 'boom'}),
    ]);

    await expectLater(repository.logout(), throwsA(isA<DioException>()));
    verify(() => tokenStorage.clearTokens()).called(1);
  });

  test('requestPasswordReset envoie l’email', () async {
    configure([const StubHttpResponse(statusCode: 204)]);

    await repository.requestPasswordReset(email: 'alex@example.com');

    expect(adapter.requests.single.path, RepositoryIdentity.forgotPasswordPath);
    expect(adapter.requests.single.data, {'email': 'alex@example.com'});
  });

  test('changePassword envoie les deux mots de passe', () async {
    configure([const StubHttpResponse(statusCode: 204)]);

    await repository.changePassword(
      currentPassword: 'Ancien12!',
      newPassword: 'NouveauPass12!',
    );

    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.path, '/api/users/password');
    expect(adapter.requests.single.data, {
      'currentPassword': 'Ancien12!',
      'newPassword': 'NouveauPass12!',
    });
  });

  test('deleteAccount envoie le mot de passe puis efface les tokens', () async {
    configure([const StubHttpResponse(statusCode: 204)]);

    await repository.deleteAccount(password: 'MotDePasse12!');

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/api/users/account');
    expect(adapter.requests.single.data, {
      'currentPassword': 'MotDePasse12!',
    });
    verify(() => tokenStorage.clearTokens()).called(1);
  });

  test('resendVerificationEmail appelle la bonne route', () async {
    configure([const StubHttpResponse(statusCode: 204)]);

    await repository.resendVerificationEmail();

    expect(adapter.requests.single.path, '/api/auth/resend-verification');
  });
}
