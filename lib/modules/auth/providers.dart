import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sly_killer_template/core/network/auth/auth_state/auth_session_controller.dart';
import 'package:sly_killer_template/core/repository/repository_executor.dart';

import '../../core/network/network_providers.dart';
import '../../core/network/auth/token_store/token_store.dart';
import '../../core/network/auth/auth_state/token_pair.dart';

import 'data/api/auth_api.dart';
import 'data/config/auth_config.dart';
import 'data/services/all_auth.dart';

final authConfigProvider = Provider<AuthConfig>((ref) {
  return AuthConfig(
    loginPath: '/auth/login',
    signupPath: '/auth/signup',
    logoutPath: '/auth/logout',
    tokenParser: (json) {
      // Default assumption; change per backend WITHOUT touching AllAuth.
      if (json is! Map<String, dynamic>) {
        throw StateError('Invalid token response');
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

final authApiProvider = Provider<AuthApi>((ref) {
  final RepositoryExecutor exec = ref.read(repositoryExecutorProvider);
  return AuthApi(exec);
});

final allAuthProvider = Provider<AllAuth>((ref) {
  final TokenStore store = ref.read(tokenStoreProvider);

  return AllAuth(
    api: ref.read(authApiProvider),
    tokenStore: store,
    config: ref.read(authConfigProvider),
    session: ref.read(authSessionControllerProvider.notifier),
  );
});
