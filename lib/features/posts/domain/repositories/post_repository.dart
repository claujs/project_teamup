import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts();
  Future<Either<Failure, List<Post>>> getCachedPosts();
  Future<void> cachePosts(List<Post> posts);
  Future<Either<Failure, Post>> likePost(String postId, String userId);
  Future<Either<Failure, Post>> unlikePost(String postId, String userId);
  Future<Either<Failure, Post>> addComment(
    String postId,
    String content,
    String userId,
    String userName,
    String userAvatar,
  );
}
