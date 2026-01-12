import '../auth_state/token_pair.dart';

class TokenRefreshConfig {
  /// e.g. "/auth/refresh"
  final String refreshPath;

  /// Build refresh request payload from refresh token.
  final Map<String, dynamic> Function(String refreshToken) bodyBuilder;

  /// Parse token response into TokenPair.
  final TokenPair Function(dynamic json) parser;

  const TokenRefreshConfig({
    required this.refreshPath,
    required this.bodyBuilder,
    required this.parser,
  });
}
