import 'dart:convert';
import 'package:http/http.dart' as http;

import '../request/api_request.dart';
import '../response/raw_api_response.dart';
import 'network_transport.dart';

class HttpNetworkTransport implements NetworkTransport {
  final http.Client _client;

  const HttpNetworkTransport(this._client);

  @override
  Future<RawApiResponse> send(
    ApiRequest request, {
    required String baseUrl,
  }) async {
    final uri = _buildUri(baseUrl, request.path, request.queryParameters);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?request.headers,
    };

    http.Response res;

    switch (request.method) {
      case HttpMethod.get:
        res = await _client.get(uri, headers: headers);
        break;
      case HttpMethod.post:
        res = await _client.post(
          uri,
          headers: headers,
          body: _encodeBody(request.body),
        );
        break;
      case HttpMethod.put:
        res = await _client.put(
          uri,
          headers: headers,
          body: _encodeBody(request.body),
        );
        break;
      case HttpMethod.patch:
        res = await _client.patch(
          uri,
          headers: headers,
          body: _encodeBody(request.body),
        );
        break;
      case HttpMethod.delete:
        res = await _client.delete(
          uri,
          headers: headers,
          body: _encodeBody(request.body),
        );
        break;
    }

    return RawApiResponse(
      statusCode: res.statusCode,
      body: res.body,
      headers: res.headers,
    );
  }

  Uri _buildUri(String baseUrl, String path, Map<String, String>? query) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  String? _encodeBody(Map<String, dynamic>? body) {
    if (body == null) return null;
    return jsonEncode(body);
  }
}
