import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/features/profile/data/repository_profile.dart';
import 'package:ironpath/features/profile/domain/models/profile_input.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

Response<dynamic> response(Object? data, {int statusCode = 200}) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
      data: data,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late MockApiClient apiClient;
  late RepositoryProfile repository;

  setUp(() {
    apiClient = MockApiClient();
    repository = RepositoryProfile(apiClient);
  });

  test('getProfile retourne null pour une réponse 204', () async {
    when(() => apiClient.get('/api/profile'))
        .thenAnswer((_) async => response(null, statusCode: 204));

    expect(await repository.getProfile(), isNull);
  });

  test('getProfile retourne null pour une chaîne vide', () async {
    when(() => apiClient.get('/api/profile'))
        .thenAnswer((_) async => response(''));

    expect(await repository.getProfile(), isNull);
  });

  test('getProfile convertit la réponse', () async {
    when(() => apiClient.get('/api/profile'))
        .thenAnswer((_) async => response(profileJson()));

    final profile = await repository.getProfile();

    expect(profile?.username, 'alexmartin');
  });

  test('getProfile refuse une réponse invalide', () async {
    when(() => apiClient.get('/api/profile'))
        .thenAnswer((_) async => response(['invalid']));

    await expectLater(repository.getProfile(), throwsA(isA<FormatException>()));
  });

  test('updateProfile envoie le JSON et convertit la réponse', () async {
    const input = ProfileInput(firstName: 'Alex', username: 'alexmartin');
    when(
      () => apiClient.put(
        '/api/profile',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response(profileJson()));

    final profile = await repository.updateProfile(input);

    expect(profile.firstName, 'Alex');
    final captured = verify(
      () => apiClient.put(
        '/api/profile',
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured, input.toJson());
  });

  test('updateProfile refuse une réponse invalide', () async {
    const input = ProfileInput(firstName: 'Alex');
    when(
      () => apiClient.put(
        '/api/profile',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => response('invalid'));

    await expectLater(
      repository.updateProfile(input),
      throwsA(isA<FormatException>()),
    );
  });
}
