import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    required int total,
    @JsonKey(name: 'total_pages') required int totalPages,
    required List<User> data,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}
