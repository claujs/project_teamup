import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalUserService {
  static const String _usersBoxName = 'registered_users';
  static const String _credentialsBoxName = 'saved_credentials';
  static const String _credentialsKey = 'user_credentials';

  late Box<dynamic> _usersBox;
  late Box<dynamic> _credentialsBox;

  static final LocalUserService _instance = LocalUserService._internal();
  factory LocalUserService() => _instance;
  LocalUserService._internal();

  Future<void> init() async {
    try {
      _usersBox = await Hive.openBox<dynamic>(_usersBoxName);
      _credentialsBox = await Hive.openBox<dynamic>(_credentialsBoxName);
    } catch (e) {
      print('Error opening Hive boxes, clearing corrupted data: $e');
      // Em caso de erro, tentar limpar e recriar as boxes
      await _clearCorruptedData();
      _usersBox = await Hive.openBox<dynamic>(_usersBoxName);
      _credentialsBox = await Hive.openBox<dynamic>(_credentialsBoxName);
    }
  }

  Future<void> _clearCorruptedData() async {
    try {
      await Hive.deleteBoxFromDisk(_usersBoxName);
      await Hive.deleteBoxFromDisk(_credentialsBoxName);
    } catch (e) {
      print('Error clearing corrupted data: $e');
    }
  }

  // Métodos para gerenciar usuários cadastrados
  Future<bool> registerUser(
    String email,
    String fullName,
    String password,
  ) async {
    try {
      // Verificar se o usuário já existe
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

      print('getUser - Type of result: ${result.runtimeType}');

      // Sempre fazer conversão segura para garantir o tipo correto
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print('getUser - Result is not a Map: $result');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
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
      print('Error validating user: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return _usersBox.values
          .where((user) => user is Map)
          .map((user) => Map<String, dynamic>.from(user as Map))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Métodos para gerenciar credenciais salvas
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

      print('getSavedCredentials - Type of result: ${result.runtimeType}');

      // Sempre fazer conversão segura para garantir o tipo correto
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      } else {
        print('getSavedCredentials - Result is not a Map: $result');
        return null;
      }
    } catch (e) {
      print('Error getting saved credentials: $e');
      return null;
    }
  }

  Future<void> clearSavedCredentials() async {
    await _credentialsBox.delete(_credentialsKey);
  }

  Future<bool> hasSavedCredentials() async {
    return _credentialsBox.containsKey(_credentialsKey);
  }

  // Método auxiliar para hash da senha
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Método para limpar todos os dados
  Future<void> clearAllData() async {
    try {
      await _usersBox.clear();
      await _credentialsBox.clear();

      // Forçar recriação das boxes para garantir tipos corretos
      await _usersBox.close();
      await _credentialsBox.close();

      await Hive.deleteBoxFromDisk(_usersBoxName);
      await Hive.deleteBoxFromDisk(_credentialsBoxName);

      // Reabrir as boxes
      _usersBox = await Hive.openBox<dynamic>(_usersBoxName);
      _credentialsBox = await Hive.openBox<dynamic>(_credentialsBoxName);

      print('All user data cleared and boxes recreated');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
