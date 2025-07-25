import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saved_credentials.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class SavedCredentials extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final DateTime lastLogin;

  @HiveField(3)
  final bool rememberMe;

  SavedCredentials({
    required this.email,
    required this.password,
    required this.lastLogin,
    this.rememberMe = true,
  });

  factory SavedCredentials.fromJson(Map<String, dynamic> json) =>
      _$SavedCredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$SavedCredentialsToJson(this);

  SavedCredentials copyWith({
    String? email,
    String? password,
    DateTime? lastLogin,
    bool? rememberMe,
  }) {
    return SavedCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
      lastLogin: lastLogin ?? this.lastLogin,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
