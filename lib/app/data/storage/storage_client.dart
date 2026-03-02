import 'package:get_storage/get_storage.dart';

class StorageClient {
  static final _box = GetStorage();

  // Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Token management
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

  static Future<void> clearSession() async {
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
  }
}
