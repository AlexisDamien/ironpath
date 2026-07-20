import 'package:dio/dio.dart';

String formatExceptionMessage(
  Object error, {
  String fallback = 'Une erreur est survenue',
}) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final errorMessage = data['error'];
      if (errorMessage is String && errorMessage.isNotEmpty) {
        return errorMessage;
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Impossible de contacter le serveur';
    }
  }

  final normalizedMessage = error.toString().replaceFirst('Exception: ', '');
  return normalizedMessage.isEmpty ? fallback : normalizedMessage;
}
