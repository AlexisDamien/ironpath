import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class StubHttpResponse {
  final int statusCode;
  final Object? data;
  final Map<String, List<String>> headers;

  const StubHttpResponse({
    this.statusCode = 200,
    this.data,
    this.headers = const {},
  });
}

class RecordingHttpClientAdapter implements HttpClientAdapter {
  final List<StubHttpResponse> responses;
  final List<RequestOptions> requests = [];
  var _index = 0;

  RecordingHttpClientAdapter(this.responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_index >= responses.length) {
      throw StateError('Aucune réponse HTTP configurée pour ${options.path}');
    }

    final stub = responses[_index++];
    final headers = <String, List<String>>{
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...stub.headers,
    };

    return ResponseBody.fromString(
      stub.data == null ? '' : jsonEncode(stub.data),
      stub.statusCode,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
