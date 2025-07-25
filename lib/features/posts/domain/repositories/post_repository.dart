import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts();
  Future<Either<Failure, List<Post>>> getCachedPosts();
  Future<void> cachePosts(List<Post> posts);
}
