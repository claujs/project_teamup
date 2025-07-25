import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    required String token,
    String? firstName,
    String? lastName,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

extension AuthUserX on AuthUser {
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}';
}
