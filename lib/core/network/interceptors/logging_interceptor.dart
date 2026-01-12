import 'package:sly_killer_template/core/utils/logger/app_logger.dart';

import '../request/api_request.dart';
import '../response/raw_api_response.dart';
import 'network_interceptor.dart';

class LoggingInterceptor extends NetworkInterceptor {
  final Logger logger;

  /// If true, logs request/response bodies (careful in production).
  final bool logBodies;

  /// Headers to redact if present.
  final Set<String> redactHeaders;

  const LoggingInterceptor(
    this.logger, {
    this.logBodies = false,
    this.redactHeaders = const {'authorization'},
  });

  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    logger.i('>> ${request.method.name.toUpperCase()} ${request.path}');

    final headers = _redact(request.headers);
    if (headers != null && headers.isNotEmpty) {
      logger.d('Headers: $headers');
    }

    if (request.queryParameters != null &&
        request.queryParameters!.isNotEmpty) {
      logger.d('Query: ${request.queryParameters}');
    }

    if (logBodies && request.body != null) {
      logger.d('Body: ${request.body}');
    }

    return request;
  }

  @override
  Future<RawApiResponse> onResponse(RawApiResponse response) async {
    logger.i('<< ${response.statusCode}');

    final headers = _redact(response.headers);
    if (headers!.isNotEmpty) {
      logger.d('Resp Headers: $headers');
    }

    if (logBodies) {
      final body = response.body;
      if (body.isNotEmpty) {
        // Avoid logging huge bodies
        final clipped = body.length > 2000
            ? '${body.substring(0, 2000)}...(clipped)'
            : body;
        logger.d('Resp Body: $clipped');
      }
    }

    return response;
  }

  Map<String, String>? _redact(Map<String, String>? headers) {
    if (headers == null) return null;

    final out = <String, String>{};
    headers.forEach((k, v) {
      final keyLower = k.toLowerCase();
      out[k] = redactHeaders.contains(keyLower) ? '***' : v;
    });
    return out;
  }
}
