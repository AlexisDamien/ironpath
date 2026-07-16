import 'package:dio/dio.dart';
import '../../../core/storage/token_storage.dart';

class RepositoryIdentity {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  RepositoryIdentity({
    required Dio dio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  Future<void> register({
    required String email,
    required String password,
    required bool rgpdConsent,
  }) async {
    await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'rgpdConsent': rgpdConsent,
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    await _tokenStorage.saveTokens(
      accessToken: response.data['token'],
      refreshToken: response.data['refreshToken'],
    );
  }

  Future<void> logout() async {
    await _dio.post('/users/logout');
    await _tokenStorage.clearTokens();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put('/users/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> deleteAccount({required String password}) async {
    await _dio.delete('/users/account', data: {
      'currentPassword': password,
    });
  }

  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    await _dio.put('/users/email', data: {
      'currentPassword': currentPassword,
      'newEmail': newEmail,
    });
  }
}
