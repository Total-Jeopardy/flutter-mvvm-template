import 'package:sly_killer_template/core/network/auth/auth_state/auth_session_controller.dart';

import '../../../../core/network/auth/auth_state/token_pair.dart';
import '../../../../core/network/auth/token_store/token_store.dart';
import '../../../../core/result/api_result/result.dart';
import '../api/auth_api.dart';
import '../config/auth_config.dart';

class AllAuth {
  final AuthApi _api;
  final TokenStore _tokenStore;
  final AuthConfig _config;
  final AuthSessionController _session;

  const AllAuth({
    required AuthApi api,
    required TokenStore tokenStore,
    required AuthConfig config,
    required AuthSessionController session,
  }) : _api = api,
       _tokenStore = tokenStore,
       _config = config,
       _session = session;

  /// Lean default: email/username + password login.
  /// `payload` is flexible so you can pass {"email": "..."} or {"username": "..."} etc.
  Future<Result<TokenPair>> login({
    required Map<String, dynamic> payload,
  }) async {
    final res = await _api.login(path: _config.loginPath, body: payload);

    return res.when(
      success: (json) async {
        final tokens = _config.tokenParser(json);
        await _tokenStore.write(tokens);
        _session.setAuthenticated();
        return Success(tokens);
      },
      failure: (error) async => Failure(error),
    );
  }

  /// Signup supports ANY payload shape.
  Future<Result<TokenPair>> signup({
    required Map<String, dynamic> payload,
  }) async {
    final res = await _api.signup(path: _config.signupPath, body: payload);

    return res.when(
      success: (json) async {
        final tokens = _config.tokenParser(json);
        await _tokenStore.write(tokens);
        _session.setAuthenticated();
        return Success(tokens);
      },
      failure: (error) async => Failure(error),
    );
  }

  /// Logout is optional (some backends don't have it).
  /// Always clears local tokens even if server logout fails (configurable later).
  Future<Result<void>> logout({Map<String, dynamic>? payload}) async {
    final path = _config.logoutPath;

    if (path == null || path.isEmpty) {
      await _tokenStore.clear();
      _session.setUnauthenticated();
      return const Success(null);
    }

    final res = await _api.logout(path: path, body: payload);

    return res.when(
      success: (_) async {
        await _tokenStore.clear();
        _session.setUnauthenticated();
        return const Success(null);
      },
      failure: (error) async {
        // Template decision: clear locally anyway to guarantee sign-out UX.
        await _tokenStore.clear();
        _session.setUnauthenticated();
        return Failure(error);
      },
    );
  }

  Future<TokenPair?> currentTokens() => _tokenStore.read();

  Future<void> clearTokens() async {
    await _tokenStore.clear();
    _session.setUnauthenticated();
  }
}
