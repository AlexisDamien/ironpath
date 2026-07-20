import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  return ApiClient(tokenStorage: tokenStorage);
});

class ApiClient {
  static const Set<String> _publicAuthPaths = {
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/verify-email',
    '/api/auth/refresh',
    '/api/auth/forgot-password',
  };

  final TokenStorage tokenStorage;

  late final Dio dio;
  late final Dio _refreshDio;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(_createBaseOptions());
    _refreshDio = Dio(_createBaseOptions());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _addAuthorizationHeader,
        onError: _handleUnauthorized,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> _addAuthorizationHeader(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublicAuthRequest = _publicAuthPaths.any(options.path.endsWith);
    if (isPublicAuthRequest) {
      handler.next(options);
      return;
    }

    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  Future<void> _handleUnauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;

    final isPublicAuthRequest = _publicAuthPaths.any(request.path.endsWith);

    final alreadyRetried = request.extra['retriedAfterRefresh'] == true;

    if (error.response?.statusCode != 401 ||
        isPublicAuthRequest ||
        alreadyRetried) {
      handler.next(error);
      return;
    }

    final refreshToken = await tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStorage.clearTokens();
      handler.next(error);
      return;
    }

    request.extra['retriedAfterRefresh'] = true;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final responseData = response.data;
      final newAccessToken = responseData?['token'];
      final returnedRefreshToken = responseData?['refreshToken'];

      if (newAccessToken is! String || newAccessToken.isEmpty) {
        throw const FormatException('Réponse de refresh invalide');
      }

      final newRefreshToken =
          returnedRefreshToken is String && returnedRefreshToken.isNotEmpty
          ? returnedRefreshToken
          : refreshToken;

      final persistSession = await tokenStorage.shouldRestoreSession();
      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        persist: persistSession,
      );

      request.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await dio.fetch<dynamic>(request);

      handler.resolve(retryResponse);
    } catch (exception) {
      if (kDebugMode) {
        debugPrint('Échec du renouvellement du token : $exception');
      }

      await tokenStorage.clearTokens();
      handler.next(error);
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<dynamic>(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {Map<String, dynamic>? data}) {
    return dio.post<dynamic>(path, data: data);
  }

  Future<Response<dynamic>> put(String path, {Map<String, dynamic>? data}) {
    return dio.put<dynamic>(path, data: data);
  }

  Future<Response<dynamic>> delete(String path) {
    return dio.delete<dynamic>(path);
  }
}
