import 'package:flutter_riverpod/legacy.dart';
import 'package:sly_killer_template/core/network/auth/auth_state/auth_session.dart';

import '../token_store/token_store.dart';
import '../../network_providers.dart';

class AuthSessionController extends StateNotifier<AuthSession> {
  AuthSessionController(this._tokenStore) : super(AuthSession.unauthenticated);

  final TokenStore _tokenStore;

  Future<void> hydrate() async {
    final tokens = await _tokenStore.read();
    state = (tokens == null)
        ? AuthSession.unauthenticated
        : AuthSession.authenticated;
  }

  void setAuthenticated() => state = AuthSession.authenticated;
  void setUnauthenticated() => state = AuthSession.unauthenticated;
}

final authSessionControllerProvider =
    StateNotifierProvider<AuthSessionController, AuthSession>((ref) {
      final store = ref.read(tokenStoreProvider);
      final controller = AuthSessionController(store);

      // hydrate once
      controller.hydrate();

      return controller;
    });
