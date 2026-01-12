import 'package:sly_killer_template/core/repository/repository_executor.dart';

import '../../../../core/network/request/api_request.dart';
import '../../../../core/result/api_result/result.dart';

class AuthApi {
  final RepositoryExecutor _exec;

  const AuthApi(this._exec);

  Future<Result<dynamic>> login({
    required String path,
    required Map<String, dynamic> body,
  }) {
    return _exec.execute<dynamic, dynamic>(
      request: ApiRequest(method: HttpMethod.post, path: path, body: body),
      parser: (json) => json,
      mapper: (data) => data,
    );
  }

  Future<Result<dynamic>> signup({
    required String path,
    required Map<String, dynamic> body,
  }) {
    return _exec.execute<dynamic, dynamic>(
      request: ApiRequest(method: HttpMethod.post, path: path, body: body),
      parser: (json) => json,
      mapper: (data) => data,
    );
  }

  Future<Result<void>> logout({
    required String path,
    Map<String, dynamic>? body,
  }) {
    return _exec.executeVoid(
      request: ApiRequest(method: HttpMethod.post, path: path, body: body),
    );
  }
}
