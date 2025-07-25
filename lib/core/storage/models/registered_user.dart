import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'registered_user.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class RegisteredUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String firstName;

  @HiveField(4)
  final String lastName;

  @HiveField(5)
  final String hashedPassword;

  @HiveField(6)
  final DateTime createdAt;

  RegisteredUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.hashedPassword,
    required this.createdAt,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) =>
      _$RegisteredUserFromJson(json);

  Map<String, dynamic> toJson() => _$RegisteredUserToJson(this);

  RegisteredUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? hashedPassword,
    DateTime? createdAt,
  }) {
    return RegisteredUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
