import 'package:get_storage/get_storage.dart';

class StorageClient {
  static final _box = GetStorage();

  // Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserType = 'user_type';
  static const String _keyTokenExpiry = 'token_expiry'; // unix timestamp (seconds)

  // ── Token management ──────────────────────────────────────
  static Future<void> saveToken(String accessToken, String refreshToken) async {
    await _box.write(_keyAccessToken, accessToken);
    await _box.write(_keyRefreshToken, refreshToken);
  }

  static String? getAccessToken() {
    return _box.read<String>(_keyAccessToken);
  }

  static String? getRefreshToken() {
    return _box.read<String>(_keyRefreshToken);
  }

  // ── User type ─────────────────────────────────────────────
  static Future<void> saveUserType(String userType) async {
    await _box.write(_keyUserType, userType);
  }

  static String? getUserType() {
    return _box.read<String>(_keyUserType);
  }

  // ── Expiry ────────────────────────────────────────────────
  /// [expiryUnixSeconds]: nilai `exp` dari JWT payload
  static Future<void> saveTokenExpiry(int expiryUnixSeconds) async {
    await _box.write(_keyTokenExpiry, expiryUnixSeconds);
  }

  /// Mengembalikan `true` jika token sudah expired atau belum pernah disimpan.
  static bool isTokenExpired() {
    final expiry = _box.read<int>(_keyTokenExpiry);
    if (expiry == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiry;
  }

  // ── Clear ─────────────────────────────────────────────────
  static Future<void> clearSession() async {
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUserType);
    await _box.remove(_keyTokenExpiry);
  }
}
