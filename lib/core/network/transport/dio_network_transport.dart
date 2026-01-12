import '../request/api_request.dart';
import '../response/raw_api_response.dart';
import 'network_transport.dart';

/// Placeholder to keep the template ready.
/// Only implement when you add dio to pubspec.
class DioNetworkTransport implements NetworkTransport {
  const DioNetworkTransport();

  @override
  Future<RawApiResponse> send(ApiRequest request, {required String baseUrl}) {
    throw UnimplementedError(
      'Add dio dependency and implement DioNetworkTransport.',
    );
  }
}
