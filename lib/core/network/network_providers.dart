import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sly_killer_template/core/network/auth/token_store/secure_token_store.dart';
import 'package:sly_killer_template/core/network/interceptors/logging_interceptor.dart';
import 'package:sly_killer_template/core/repository/repository_executor.dart';
import 'package:sly_killer_template/core/utils/logger/logger_providers.dart';

import '../config/app_config/app_config.dart';
import '../config/env/env.dart';

import 'api_client/api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/network_interceptor.dart';
import 'transport/http_network_transport.dart';
import 'transport/network_transport.dart';

import 'auth/auth_state/token_pair.dart';
import 'auth/token_refresher/default_token_refresher.dart';
import 'auth/token_refresher/token_refresh_config.dart';
import 'auth/token_refresher/token_refresher.dart';
import 'auth/token_store/token_store.dart';

/// 1) App config provider (per app you change Env, not this wiring)
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(apiBaseUrl: Env.apiBaseUrl);
});

/// 2) HTTP client (replace with custom client if you want)
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// 3) Transport (HTTP now; swap to Dio later by replacing this provider)
final networkTransportProvider = Provider<NetworkTransport>((ref) {
  return HttpNetworkTransport(ref.read(httpClientProvider));
});

/// 4) Token store (secure storage by default; swap if needed)
final tokenStoreProvider = Provider<TokenStore>((ref) {
  final storage = SecureTokenStore.buildDefaultStorage();
  return SecureTokenStore(storage);
});

/// 5) Token refresh config (THIS is per-app customizable)
final tokenRefreshConfigProvider = Provider<TokenRefreshConfig>((ref) {
  return TokenRefreshConfig(
    refreshPath: '/auth/refresh',
    bodyBuilder: (refreshToken) => {'refresh_token': refreshToken},
    parser: (json) {
      // Expected shape example:
      // { "access_token": "...", "refresh_token": "...", "expires_at": "2026-01-12T12:00:00Z" }
      if (json is! Map<String, dynamic>) {
        throw StateError('Invalid refresh response');
      }

      final access = (json['access_token'] ?? '').toString();
      final refresh = (json['refresh_token'] ?? '').toString();

      DateTime? expiresAt;
      final exp = json['expires_at'];
      if (exp is String && exp.isNotEmpty) {
        expiresAt = DateTime.tryParse(exp);
      }

      return TokenPair(
        accessToken: access,
        refreshToken: refresh,
        accessTokenExpiresAt: expiresAt,
      );
    },
  );
});

/// 6) Token refresher (wired once)
final tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final cfg = ref.read(appConfigProvider);

  return DefaultTokenRefresher(
    baseUrl: cfg.apiBaseUrl,
    transport: ref.read(networkTransportProvider),
    tokenStore: ref.read(tokenStoreProvider),
    config: ref.read(tokenRefreshConfigProvider),
  );
});

/// 7) Interceptors list (extend here globally)
final networkInterceptorsProvider = Provider<List<NetworkInterceptor>>((ref) {
  final logger = ref.read(loggerProvider);

  final interceptors = <NetworkInterceptor>[
    AuthInterceptor(ref.read(tokenStoreProvider)),
  ];

  if (Env.enableNetworkLogging) {
    interceptors.add(
      LoggingInterceptor(logger, logBodies: Env.enableNetworkBodyLogging),
    );
  }

  return interceptors;
});

/// 8) ApiClient (the only thing features should depend on)
final apiClientProvider = Provider<ApiClient>((ref) {
  final cfg = ref.read(appConfigProvider);

  return ApiClient(
    baseUrl: cfg.apiBaseUrl,
    transport: ref.read(networkTransportProvider),
    interceptors: ref.read(networkInterceptorsProvider),
    tokenRefresher: ref.read(tokenRefresherProvider),
  );
});

final repositoryExecutorProvider = Provider<RepositoryExecutor>((ref) {
  return RepositoryExecutor(ref.read(apiClientProvider));
});
