import 'dart:async';
import 'dart:convert';

import '../../../errors/auth/auth_error.dart';
import '../../../errors/network/network_error.dart';
import '../../../result/api_result/result.dart';
import '../../request/api_request.dart';
import '../../response/raw_api_response.dart';
import '../../transport/network_transport.dart';
import '../token_store/token_store.dart';
import '../auth_state/token_pair.dart';
import 'token_refresh_config.dart';
import 'token_refresher.dart';

class DefaultTokenRefresher implements TokenRefresher {
  final String baseUrl;
  final NetworkTransport transport;
  final TokenStore tokenStore;
  final TokenRefreshConfig config;

  DefaultTokenRefresher({
    required this.baseUrl,
    required this.transport,
    required this.tokenStore,
    required this.config,
  });

  Completer<Result<void>>? _inFlight;

  @override
  Future<Result<void>> refresh() {
    // Coalesce concurrent refresh calls.
    final existing = _inFlight;
    if (existing != null) return existing.future;

    final completer = Completer<Result<void>>();
    _inFlight = completer;

    () async {
      try {
        final tokens = await tokenStore.read();
        if (tokens == null || tokens.refreshToken.isEmpty) {
          completer.complete(
            Failure(AuthError(message: 'Missing refresh token')),
          );
          return;
        }

        final req = ApiRequest(
          method: HttpMethod.post,
          path: config.refreshPath,
          body: config.bodyBuilder(tokens.refreshToken),
        );

        final RawApiResponse raw = await transport.send(req, baseUrl: baseUrl);

        if (raw.statusCode < 200 || raw.statusCode >= 300) {
          completer.complete(
            Failure(
              AuthError(
                message: 'Token refresh failed',
                code: '${raw.statusCode}',
              ),
            ),
          );
          return;
        }

        final decoded = raw.body.trim().isEmpty ? null : jsonDecode(raw.body);
        final TokenPair newTokens = config.parser(decoded);

        await tokenStore.write(newTokens);
        completer.complete(const Success(null));
      } catch (e) {
        completer.complete(Failure(NetworkError(message: e.toString())));
      } finally {
        _inFlight = null;
      }
    }();

    return completer.future;
  }
}
