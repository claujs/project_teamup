import 'package:flutter/material.dart';
import 'core/storage/local_user_service.dart';

/// Utilitário de debug para limpar storage e testar tipos
class DebugStorage {
  static Future<void> clearAllUserData() async {
    final service = LocalUserService();
    await service.clearAllData();
    debugPrint('All user data cleared successfully');
  }

  static Future<void> testUserRetrieval(String email) async {
    final service = LocalUserService();
    final user = await service.getUser(email);
    debugPrint('User retrieved: $user');
    debugPrint('User type: ${user.runtimeType}');
  }

  static Future<void> testCredentialsRetrieval() async {
    final service = LocalUserService();
    final credentials = await service.getSavedCredentials();
    debugPrint('Credentials retrieved: $credentials');
    debugPrint('Credentials type: ${credentials.runtimeType}');
  }
}
