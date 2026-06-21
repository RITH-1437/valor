import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  static Future<void> saveToken(String token) async =>
      await _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: _keyToken);

  static Future<void> deleteToken() async =>
      await _storage.delete(key: _keyToken);

  static Future<void> saveUser(Map<String, dynamic> user) async =>
      await _storage.write(key: _keyUser, value: jsonEncode(user));

  static Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: _keyUser);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> deleteUser() async =>
      await _storage.delete(key: _keyUser);

  static Future<void> logout() async {
    await deleteToken();
    await deleteUser();
  }

  static Future<bool> hasToken() async =>
      (await getToken()) != null;
}
