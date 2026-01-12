import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth_state/token_pair.dart';
import 'token_store.dart';

class SecureTokenStore implements TokenStore {
  // Keys are centralized and constant.
  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kAccessTokenExpiresAt = 'auth.access_token_expires_at';

  final FlutterSecureStorage _storage;

  const SecureTokenStore(this._storage);

  /// Recommended platform options:
  /// - Android: EncryptedSharedPreferences (uses Keystore)
  /// - iOS: Keychain, with a sane accessibility level
  static FlutterSecureStorage buildDefaultStorage() {
    const android = AndroidOptions(
      encryptedSharedPreferences: true,
      // Optional hardening knobs (generally safe defaults):
      // resetOnError: true,
    );

    const ios = IOSOptions(
      // Accessible after first unlock is a good balance for most apps.
      // If you want the strictest, use: KeychainAccessibility.unlocked
      accessibility: KeychainAccessibility.first_unlock,
      // Optional:
      // synchronizable: false, // keep tokens off iCloud Keychain sync
    );

    return const FlutterSecureStorage(aOptions: android, iOptions: ios);
  }

  @override
  Future<TokenPair?> read() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);

    if (access == null || access.isEmpty) return null;
    if (refresh == null || refresh.isEmpty) return null;

    final expRaw = await _storage.read(key: _kAccessTokenExpiresAt);
    final exp = (expRaw == null || expRaw.isEmpty)
        ? null
        : DateTime.tryParse(expRaw);

    return TokenPair(
      accessToken: access,
      refreshToken: refresh,
      accessTokenExpiresAt: exp,
    );
  }

  @override
  Future<void> write(TokenPair tokens) async {
    // Write as an atomic-ish batch to reduce partial writes.
    // flutter_secure_storage doesn't support true transactions,
    // but sequential writes are fine if we clear on error.
    try {
      await _storage.write(key: _kAccessToken, value: tokens.accessToken);
      await _storage.write(key: _kRefreshToken, value: tokens.refreshToken);

      final exp = tokens.accessTokenExpiresAt?.toIso8601String() ?? '';
      await _storage.write(key: _kAccessTokenExpiresAt, value: exp);
    } catch (_) {
      // If anything goes wrong, fail closed: clear everything.
      await clear();
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    // Delete only what we own.
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kAccessTokenExpiresAt);
  }
}
