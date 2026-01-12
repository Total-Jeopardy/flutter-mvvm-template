import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sly_killer_template/core/network/network_providers.dart';
import 'package:sly_killer_template/core/network/transport/network_transport.dart';

ProviderContainer createTestContainer({required NetworkTransport transport}) {
  return ProviderContainer(
    overrides: [networkTransportProvider.overrideWithValue(transport)],
  );
}
