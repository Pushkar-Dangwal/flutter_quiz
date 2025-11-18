import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../db/hive_service.dart';

class LocalAuthService {
  Box<Map> get _usersBox => Hive.box<Map>(HiveService.usersBoxName);
  Box<String> get _sessionBox => Hive.box<String>(HiveService.sessionBoxName);

  Future<Map<String, dynamic>> _loadUsers() async {
    // Flatten Hive box entries into a single map keyed by email
    final result = <String, dynamic>{};
    for (final key in _usersBox.keys) {
      final value = _usersBox.get(key);
      if (value != null) {
        result[key as String] = Map<String, dynamic>.from(value);
      }
    }
    return result;
  }

  Future<void> _saveUser(String email, Map<String, dynamic> user) async {
    await _usersBox.put(email, user);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> signup({required String name, required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_usersBox.containsKey(normalizedEmail)) {
      return false;
    }
    final user = {
      'name': name.trim(),
      'email': normalizedEmail,
      'passwordHash': _hashPassword(password),
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _saveUser(normalizedEmail, user);
    await _sessionBox.put(HiveService.sessionEmailKey, normalizedEmail);
    return true;
  }

  Future<bool> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final stored = _usersBox.get(normalizedEmail);
    final Map<String, dynamic>? user = stored == null ? null : Map<String, dynamic>.from(stored);
    if (user == null) return false;
    final ok = user['passwordHash'] == _hashPassword(password);
    if (!ok) return false;
    await _sessionBox.put(HiveService.sessionEmailKey, normalizedEmail);
    return true;
  }

  Future<void> logout() async {
    await _sessionBox.delete(HiveService.sessionEmailKey);
  }

  Future<Map<String, String>?> currentUser() async {
    final email = _sessionBox.get(HiveService.sessionEmailKey);
    if (email == null) return null;
    final stored = _usersBox.get(email);
    final user = stored == null ? null : Map<String, dynamic>.from(stored);
    if (user is Map<String, dynamic>) {
      return {
        'name': user['name'] as String? ?? '',
        'email': user['email'] as String? ?? '',
      };
    }
    return null;
  }
}


