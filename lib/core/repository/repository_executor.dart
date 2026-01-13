// ignore_for_file: unintended_html_in_doc_comment

import 'package:sly_killer_template/core/network/api_client/api_client.dart';
import 'package:sly_killer_template/core/network/request/api_request.dart';
import 'package:sly_killer_template/core/result/api_result/result.dart';

/// Standardized execution helper for repositories.
/// - Calls ApiClient
/// - Returns Result<T>
/// - Allows mapping API payload into domain model
class RepositoryExecutor {
  final ApiClient _apiClient;

  const RepositoryExecutor(this._apiClient);

  Future<Result<R>> execute<T, R>({
    required ApiRequest request,
    required T Function(dynamic json) parser,
    required R Function(T data) mapper,
  }) async {
    final res = await _apiClient.send<T>(request: request, parser: parser);

    return res.when(
      success: (data) => Success(mapper(data)),
      failure: (error) => Failure(error),
    );
  }

  /// For endpoints that return no meaningful body (e.g., 204).
  Future<Result<void>> executeVoid({required ApiRequest request}) async {
    final res = await _apiClient.send<dynamic>(
      request: request,
      parser: (json) => json,
    );

    return res.when(
      success: (_) => const Success(null),
      failure: (error) => Failure(error),
    );
  }
}
