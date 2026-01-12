import '../auth_state/token_pair.dart';

abstract class TokenStore {
  const TokenStore();

  Future<TokenPair?> read();
  Future<void> write(TokenPair tokens);
  Future<void> clear();
}
