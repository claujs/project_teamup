import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(toJson: true, fromJson: true)
class User with _$User {
  const factory User({
    required int id,
    required String email,
    required String firstName,
    required String lastName,
    required String avatar,
    String? position,
    String? department,
    String? bio,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as int,
        email: json['email'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        avatar: json['avatar'] as String,
        position: json['position'] as String?,
        department: json['department'] as String?,
        bio: json['bio'] as String?,
      );
    } catch (e) {
      // Log the error and provide fallback values for debugging
      debugPrint('Error parsing User from JSON: $e');
      debugPrint('JSON data: $json');
      throw Exception('Failed to parse User: $e');
    }
  }
}

extension UserX on User {
  String get fullName => '$firstName $lastName';
}
