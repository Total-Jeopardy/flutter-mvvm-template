import '../auth/token_store/token_store.dart';
import '../request/api_request.dart';
import 'network_interceptor.dart';

class AuthInterceptor extends NetworkInterceptor {
  final TokenStore tokenStore;

  const AuthInterceptor(this.tokenStore);

  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    final tokens = await tokenStore.read();
    if (tokens == null || tokens.accessToken.isEmpty) return request;

    final headers = <String, String>{
      ...?request.headers,
      'Authorization': 'Bearer ${tokens.accessToken}',
    };

    return ApiRequest(
      method: request.method,
      path: request.path,
      body: request.body,
      queryParameters: request.queryParameters,
      headers: headers,
    );
  }
}
