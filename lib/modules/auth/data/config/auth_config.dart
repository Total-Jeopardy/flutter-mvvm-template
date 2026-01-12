import '../../../../core/network/auth/auth_state/token_pair.dart';

class AuthConfig {
  /// e.g. "/auth/login"
  final String loginPath;

  /// e.g. "/auth/signup"
  final String signupPath;

  /// e.g. "/auth/logout" (optional)
  final String? logoutPath;

  /// Convert API JSON response → TokenPair (app-specific backend shape).
  final TokenPair Function(dynamic json) tokenParser;

  const AuthConfig({
    required this.loginPath,
    required this.signupPath,
    required this.tokenParser,
    this.logoutPath,
  });
}
