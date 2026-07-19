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

  Future<bool> register({
    required String email,
    required String password,
    required bool rgpdConsent,
  }) async {
    final response = await _dio.post('/api/auth/register', data: {
      'email': email,
      'password': password,
      'rgpdConsent': rgpdConsent,
    });

    await _tokenStorage.saveTokens(
      accessToken: response.data['token'],
      refreshToken: response.data['refreshToken'],
    );

    return response.data['emailVerified'] ?? false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    await _tokenStorage.saveTokens(
      accessToken: response.data['token'],
      refreshToken: response.data['refreshToken'],
    );

    return response.data['emailVerified'] ?? false;
  }

  Future<void> logout() async {
    await _dio.post('/api/users/logout');
    await _tokenStorage.clearTokens();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put('/api/users/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> deleteAccount({required String password}) async {
    await _dio.delete('/api/users/account', data: {
      'currentPassword': password,
    });
  }

  Future<bool> checkEmailVerificationStatus() async {
    final response = await _dio.get('/api/auth/email-verification-status');
    return response.data['emailVerified'] ?? false;
  }

  Future<void> resendVerificationEmail() async {
    await _dio.post('/api/auth/resend-verification');
  }
}
