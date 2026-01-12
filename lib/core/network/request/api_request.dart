enum HttpMethod { get, post, put, delete, patch }

class ApiRequest {
  final HttpMethod method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Map<String, String>? queryParameters;

  const ApiRequest({
    required this.method,
    required this.path,
    this.body,
    this.headers,
    this.queryParameters,
  });
}
