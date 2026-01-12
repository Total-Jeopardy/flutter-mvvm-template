import 'package:sly_killer_template/core/network/request/api_request.dart';
import 'package:sly_killer_template/core/network/response/raw_api_response.dart';
import 'package:sly_killer_template/core/network/transport/network_transport.dart';

typedef RouteKey = String; // e.g. "GET:/users"

class FakeNetworkTransport implements NetworkTransport {
  final Map<RouteKey, RawApiResponse> routes;

  FakeNetworkTransport({required this.routes});

  @override
  Future<RawApiResponse> send(
    ApiRequest request, {
    required String baseUrl,
  }) async {
    final key = '${request.method.name.toUpperCase()}:${request.path}';
    final res = routes[key];
    if (res == null) {
      return const RawApiResponse(
        statusCode: 404,
        body: '{"message":"Fake route not found"}',
        headers: {},
      );
    }
    return res;
  }
}
