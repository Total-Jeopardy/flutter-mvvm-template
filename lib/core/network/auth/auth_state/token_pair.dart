class TokenPair {
  final String accessToken;
  final String refreshToken;

  /// Optional: if your backend provides expiry.
  final DateTime? accessTokenExpiresAt;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
  });

  bool get isAccessTokenExpired {
    final exp = accessTokenExpiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }
}
