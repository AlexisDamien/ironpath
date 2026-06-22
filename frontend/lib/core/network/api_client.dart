import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';

  late final Dio dio;
  final FlutterSecureStorage tokenStorage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await tokenStorage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final response = await dio.post('/auth/refresh', data: {
                'refreshToken': refreshToken,
              });
              final newAccessToken = response.data['token'];
              await tokenStorage.write(
                  key: 'access_token', value: newAccessToken);
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              return handler.resolve(await dio.fetch(error.requestOptions));
            } catch (refreshError) {
              await tokenStorage.deleteAll();
            }
          }
        }
        return handler.next(error);
      },
    ));
  }
}
