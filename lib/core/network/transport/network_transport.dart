import '../request/api_request.dart';
import '../response/raw_api_response.dart';

abstract class NetworkTransport {
  const NetworkTransport();

  Future<RawApiResponse> send(ApiRequest request, {required String baseUrl});
}
