import '../../../result/api_result/result.dart';

abstract class TokenRefresher {
  const TokenRefresher();

  /// Refresh tokens (once). Returns Success on update, Failure on refresh failure.
  Future<Result<void>> refresh();
}
