import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_strings.dart';

class LocalUserService {
  static const String _usersBoxName = AppStrings.usersBoxName;
  static const String _credentialsBoxName = AppStrings.credentialsBoxName;
  static const String _credentialsKey = AppStrings.credentialsKey;

  late Box _usersBox;
  late Box _credentialsBox;

  static final LocalUserService _instance = LocalUserService._internal();
  factory LocalUserService() => _instance;
  LocalUserService._internal();

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _usersBox = await Hive.openBox(_usersBoxName);
      _credentialsBox = await Hive.openBox(_credentialsBoxName);
    } catch (e) {
      // If there's a corruption, clear the boxes and recreate
      debugPrint('Error opening Hive boxes, clearing corrupted data: $e');
      await _clearCorruptedData();
    }
  }

  Future<void> _clearCorruptedData() async {
    try {
      await Hive.deleteBoxFromDisk(_usersBoxName);
      await Hive.deleteBoxFromDisk(_credentialsBoxName);

      _usersBox = await Hive.openBox(_usersBoxName);
      _credentialsBox = await Hive.openBox(_credentialsBoxName);
    } catch (e) {
      debugPrint('Error clearing corrupted data: $e');
    }
  }

  Future<bool> registerUser(
    String email,
    String fullName,
    String password,
  ) async {
    try {
      if (await userExists(email)) {
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'fullName': fullName,
        'firstName': firstName,
        'lastName': lastName,
        'hashedPassword': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _usersBox.put(email, userData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> userExists(String email) async {
    return _usersBox.containsKey(email);
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    try {
      final result = _usersBox.get(email);
      if (result == null) return null;

      debugPrint('getUser - Type of result: ${result.runtimeType}');

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        debugPrint('getUser - Result is not a Map: $result');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<bool> validateUser(String email, String password) async {
    try {
      final userData = await getUser(email);
      if (userData == null) return false;

      final hashedPassword = _hashPassword(password);
      final storedPassword = userData['hashedPassword'];

      return storedPassword is String && storedPassword == hashedPassword;
    } catch (e) {
      debugPrint('Error validating user: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return _usersBox.values
          .whereType<Map>()
          .map((user) => Map<String, dynamic>.from(user))
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    final credentials = {
      'email': email,
      'password': password,
      'lastLogin': DateTime.now().toIso8601String(),
      'rememberMe': true,
    };

    await _credentialsBox.put(_credentialsKey, credentials);
  }

  Future<Map<String, dynamic>?> getSavedCredentials() async {
    try {
      final result = _credentialsBox.get(_credentialsKey);
      if (result == null) return null;

      debugPrint('getSavedCredentials - Type of result: ${result.runtimeType}');

      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        debugPrint('getSavedCredentials - Result is not a Map: $result');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting saved credentials: $e');
      return null;
    }
  }

  Future<void> clearSavedCredentials() async {
    await _credentialsBox.delete(_credentialsKey);
  }

  Future<bool> hasSavedCredentials() async {
    return _credentialsBox.containsKey(_credentialsKey);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> clearAllData() async {
    try {
      await _usersBox.clear();
      await _credentialsBox.clear();

      await _usersBox.close();
      await _credentialsBox.close();

      await Hive.deleteBoxFromDisk(_usersBoxName);
      await Hive.deleteBoxFromDisk(_credentialsBoxName);

      _usersBox = await Hive.openBox<dynamic>(_usersBoxName);
      _credentialsBox = await Hive.openBox<dynamic>(_credentialsBoxName);

      debugPrint('All user data cleared and boxes recreated');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }
}
