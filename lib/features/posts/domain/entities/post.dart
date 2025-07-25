import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String content,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required DateTime createdAt,
    String? imageUrl,
    @Default(0) int likesCount,
    @Default([]) List<String> tags,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
