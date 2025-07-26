import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/job_info_service.dart';

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
        firstName: (json['first_name'] ?? json['firstName']) as String,
        lastName: (json['last_name'] ?? json['lastName']) as String,
        avatar: json['avatar'] as String,
        position: json['position'] as String?,
        department: json['department'] as String?,
        bio: json['bio'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing User from JSON: $e');
      debugPrint('JSON data: $json');
      throw Exception('Failed to parse User: $e');
    }
  }
}

extension UserX on User {
  String get fullName => '$firstName $lastName';

  String getJobInfo(BuildContext context) {
    return JobInfoService.generateJobInfo(context, id);
  }

  String getJobTitle(BuildContext context) {
    return JobInfoService.generateJobTitle(context, id);
  }

  String getDepartment(BuildContext context) {
    return JobInfoService.generateDepartment(context, id);
  }

  String getLocation() {
    return JobInfoService.generateLocation(id);
  }

  String getBio() {
    return JobInfoService.generateBio(firstName);
  }
}
