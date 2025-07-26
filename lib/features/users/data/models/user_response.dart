import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_response.freezed.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    required int page,
    required int perPage,
    required int total,
    required int totalPages,
    required List<User> data,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      data: (json['data'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
    );
  }
}
