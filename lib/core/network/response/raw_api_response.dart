class RawApiResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  const RawApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });
}
