import '../request/api_request.dart';
import '../response/raw_api_response.dart';
import '../../errors/app_error/app_error.dart';

abstract class NetworkInterceptor {
  const NetworkInterceptor();

  /// Modify outgoing request (e.g., add headers, tokens, correlation id).
  Future<ApiRequest> onRequest(ApiRequest request) async => request;

  /// Inspect/modify incoming raw response (rarely needed, but useful for logging).
  Future<RawApiResponse> onResponse(RawApiResponse response) async => response;

  /// Inspect/transform errors before they bubble up.
  Future<AppError> onError(AppError error) async => error;
}
