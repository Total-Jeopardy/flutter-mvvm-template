class AuthSession {
  final bool isAuthenticated;

  const AuthSession({required this.isAuthenticated});

  static const unauthenticated = AuthSession(isAuthenticated: false);
  static const authenticated = AuthSession(isAuthenticated: true);
}
