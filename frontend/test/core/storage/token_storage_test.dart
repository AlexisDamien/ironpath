import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ironpath/core/storage/token_storage.dart';

import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterSecureStorage secureStorage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    secureStorage = MockFlutterSecureStorage();

    when(
      () => secureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => secureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    when(
      () => secureStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
  });

  test('sauvegarde une session persistante', () async {
    final storage = TokenStorage(secureStorage);

    await storage.saveTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      persist: true,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('remember_session'), isTrue);
    expect(await storage.getAccessToken(), 'access');
    expect(await storage.getRefreshToken(), 'refresh');
    verify(
      () => secureStorage.write(key: 'access_token', value: 'access'),
    ).called(1);
    verify(
      () => secureStorage.write(key: 'refresh_token', value: 'refresh'),
    ).called(1);
  });

  test('une session non persistante reste disponible en mémoire', () async {
    final storage = TokenStorage(secureStorage);

    await storage.saveTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      persist: false,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('remember_session'), isFalse);
    expect(await storage.getAccessToken(), 'access');
    expect(await storage.getRefreshToken(), 'refresh');
    verify(() => secureStorage.delete(key: 'access_token')).called(1);
    verify(() => secureStorage.delete(key: 'refresh_token')).called(1);
  });

  test('restaure les jetons sécurisés lorsque la session est mémorisée',
      () async {
    SharedPreferences.setMockInitialValues({'remember_session': true});
    when(() => secureStorage.read(key: 'access_token'))
        .thenAnswer((_) async => 'stored-access');
    when(() => secureStorage.read(key: 'refresh_token'))
        .thenAnswer((_) async => 'stored-refresh');
    final storage = TokenStorage(secureStorage);

    expect(await storage.shouldRestoreSession(), isTrue);
    expect(await storage.getAccessToken(), 'stored-access');
    expect(await storage.getRefreshToken(), 'stored-refresh');
  });

  test('ne lit pas le stockage lorsque la restauration est désactivée',
      () async {
    SharedPreferences.setMockInitialValues({'remember_session': false});
    final storage = TokenStorage(secureStorage);

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    verifyNever(() => secureStorage.read(key: any(named: 'key')));
  });

  test('les anciennes installations tentent une restauration par défaut',
      () async {
    final storage = TokenStorage(secureStorage);
    expect(await storage.shouldRestoreSession(), isTrue);
  });

  test('clearTokens supprime la mémoire et le stockage', () async {
    final storage = TokenStorage(secureStorage);
    await storage.saveTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    await storage.clearTokens();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('remember_session'), isFalse);
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    verify(() => secureStorage.delete(key: 'access_token')).called(1);
    verify(() => secureStorage.delete(key: 'refresh_token')).called(1);
  });
}
