import 'package:dio/dio.dart';

import '../../../core/storage/token_storage.dart';

class RepositoryIdentity {
  static const String forgotPasswordPath = '/api/auth/forgot-password';

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
      persist: true,
    );

    return response.data['emailVerified'] ?? false;
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    await _tokenStorage.saveTokens(
      accessToken: response.data['token'],
      refreshToken: response.data['refreshToken'],
      persist: rememberMe,
    );

    return response.data['emailVerified'] ?? false;
  }

  Future<bool?> restoreSession() async {
    if (!await _tokenStorage.shouldRestoreSession()) return null;

    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      return null;
    }

    try {
      return await checkEmailVerificationStatus();
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/users/logout');
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post(forgotPasswordPath, data: {
      'email': email,
    });
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
    await _tokenStorage.clearTokens();
  }

  Future<bool> checkEmailVerificationStatus() async {
    final response = await _dio.get('/api/auth/email-verification-status');
    return response.data['emailVerified'] ?? false;
  }

  Future<void> resendVerificationEmail() async {
    await _dio.post('/api/auth/resend-verification');
  }
}
