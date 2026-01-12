import 'dart:convert';

import '../../errors/app_error/app_error.dart';
import '../../errors/network/network_error.dart';
import '../../errors/auth/auth_error.dart';
import '../../errors/validation/validation_error.dart';
import '../../result/api_result/result.dart';

import '../auth/token_refresher/token_refresher.dart';
import '../interceptors/network_interceptor.dart';
import '../request/api_request.dart';
import '../response/raw_api_response.dart';
import '../transport/network_transport.dart';

class ApiClient {
  final String baseUrl;
  final NetworkTransport transport;
  final List<NetworkInterceptor> interceptors;

  /// Optional: if provided, ApiClient can refresh and retry once on 401/403.
  final TokenRefresher? tokenRefresher;

  const ApiClient({
    required this.baseUrl,
    required this.transport,
    this.interceptors = const [],
    this.tokenRefresher,
  });

  Future<Result<T>> send<T>({
    required ApiRequest request,
    required T Function(dynamic json) parser,
  }) async {
    return _sendInternal<T>(
      request: request,
      parser: parser,
      allowRefreshRetry: true,
    );
  }

  Future<Result<T>> _sendInternal<T>({
    required ApiRequest request,
    required T Function(dynamic json) parser,
    required bool allowRefreshRetry,
  }) async {
    try {
      // 1) Request interceptors
      var processedRequest = request;
      for (final i in interceptors) {
        processedRequest = await i.onRequest(processedRequest);
      }

      // 2) Transport call
      RawApiResponse raw = await transport.send(
        processedRequest,
        baseUrl: baseUrl,
      );

      // 3) Response interceptors
      for (final i in interceptors) {
        raw = await i.onResponse(raw);
      }

      // 4) Success path
      if (_isSuccess(raw.statusCode)) {
        final decoded = _tryDecodeJson(raw.body);
        final data = parser(decoded);
        return Success(data);
      }

      // 5) Auto refresh on unauthorized (once)
      final isUnauthorized = raw.statusCode == 401 || raw.statusCode == 403;
      if (isUnauthorized && allowRefreshRetry && tokenRefresher != null) {
        final refreshResult = await tokenRefresher!.refresh();
        if (refreshResult is Success<void>) {
          // retry once; interceptors will attach the new token
          return _sendInternal<T>(
            request: request,
            parser: parser,
            allowRefreshRetry: false,
          );
        }
        // refresh failed -> fall through to AuthError below
      }

      // 6) Normalize errors
      AppError appError = _mapToAppError(raw);

      // 7) Error interceptors
      for (final i in interceptors) {
        appError = await i.onError(appError);
      }

      return Failure(appError);
    } catch (e) {
      AppError appError = NetworkError(message: e.toString());
      for (final i in interceptors) {
        appError = await i.onError(appError);
      }
      return Failure(appError);
    }
  }

  bool _isSuccess(int code) => code >= 200 && code < 300;

  dynamic _tryDecodeJson(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  AppError _mapToAppError(RawApiResponse raw) {
    final decoded = _tryDecodeJson(raw.body);

    if (raw.statusCode == 401 || raw.statusCode == 403) {
      return AuthError(
        message: _extractMessage(decoded) ?? 'Unauthorized',
        code: '${raw.statusCode}',
      );
    }

    if (raw.statusCode == 400 || raw.statusCode == 422) {
      final fieldErrors = _extractFieldErrors(decoded);
      return ValidationError(
        message: _extractMessage(decoded) ?? 'Validation error',
        fieldErrors: fieldErrors,
        code: '${raw.statusCode}',
      );
    }

    return NetworkError(
      message: _extractMessage(decoded) ?? 'Request failed',
      code: '${raw.statusCode}',
    );
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final msg = decoded['message'] ?? decoded['detail'] ?? decoded['error'];
      if (msg is String) return msg;
    }
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic decoded) {
    final out = <String, String>{};

    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors is Map<String, dynamic>) {
        for (final entry in errors.entries) {
          out[entry.key] = _stringifyFieldError(entry.value);
        }
        return out;
      }

      for (final entry in decoded.entries) {
        if (entry.value is String || entry.value is List) {
          out[entry.key] = _stringifyFieldError(entry.value);
        }
      }
    }

    return out;
  }

  String _stringifyFieldError(dynamic v) {
    if (v is String) return v;
    if (v is List && v.isNotEmpty) return v.first.toString();
    return v.toString();
  }
}
