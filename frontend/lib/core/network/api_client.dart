import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';

  late final Dio dio;
  late final Dio _refreshDio;

  final TokenStorage tokenStorage;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        final statusCode = error.response?.statusCode;

        final isRefreshRequest = request.path.endsWith('/auth/refresh');

        final alreadyRetried = request.extra['retriedAfterRefresh'] == true;

        // Aucun refresh si :
        // - l'erreur n'est pas un 401 ;
        // - la requête est déjà celle du refresh ;
        // - la requête a déjà été rejouée une fois.
        if (statusCode != 401 || isRefreshRequest || alreadyRetried) {
          return handler.next(error);
        }

        final refreshToken = await tokenStorage.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          await tokenStorage.clearTokens();
          return handler.next(error);
        }

        // Empêche une seconde tentative pour cette requête.
        request.extra['retriedAfterRefresh'] = true;

        late final String newAccessToken;
        String newRefreshToken = refreshToken;

        try {
          final response = await _refreshDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {
              'refreshToken': refreshToken,
            },
          );

          final responseData = response.data;
          final tokenValue = responseData?['token'];

          if (tokenValue is! String || tokenValue.isEmpty) {
            throw StateError(
              'Le serveur n’a pas renvoyé de nouveau token',
            );
          }

          newAccessToken = tokenValue;

          final returnedRefreshToken = responseData?['refreshToken'];

          if (returnedRefreshToken is String &&
              returnedRefreshToken.isNotEmpty) {
            newRefreshToken = returnedRefreshToken;
          }

          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
        } catch (_) {
          // On supprime les tokens uniquement si le refresh échoue.
          await tokenStorage.clearTokens();
          return handler.next(error);
        }

        request.headers['Authorization'] = 'Bearer $newAccessToken';

        try {
          final retryResponse = await dio.fetch(request);
          return handler.resolve(retryResponse);
        } on DioException catch (retryError) {
          // La requête a déjà été rejouée :
          // on transmet désormais son erreur à l'application.
          return handler.next(retryError);
        }
      },
    ));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
