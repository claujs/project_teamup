import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/providers.dart';
import '../domain/entities/post.dart';
import '../domain/repositories/post_repository.dart';

part 'posts_notifier.freezed.dart';

@freezed
class PostsState with _$PostsState {
  const factory PostsState.initial() = _Initial;
  const factory PostsState.loading() = _Loading;
  const factory PostsState.loaded(List<Post> posts) = _Loaded;
  const factory PostsState.error(String message) = _Error;
}

class PostsNotifier extends StateNotifier<PostsState> {
  final PostRepository _postRepository;

  PostsNotifier(this._postRepository) : super(const PostsState.initial());

  Future<void> loadPosts({bool refresh = false}) async {
    state = const PostsState.loading();

    final result = await _postRepository.getPosts();
    result.fold(
      (failure) => state = PostsState.error(failure.message),
      (posts) => state = PostsState.loaded(posts),
    );
  }
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, PostsState>((
  ref,
) {
  return PostsNotifier(ref.watch(postRepositoryProvider));
});
