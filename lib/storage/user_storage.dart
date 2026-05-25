import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorage {

  static const _storage =
  FlutterSecureStorage();

  static Future<void> saveUser(
      Map<String, dynamic> user,
      ) async {

    await _storage.write(
      key: 'user',
      value: jsonEncode(user),
    );
  }

  static Future<Map<String, dynamic>?>
  getUser() async {

    final user =
    await _storage.read(key: 'user');

    if (user == null) return null;

    return jsonDecode(user);
  }
}