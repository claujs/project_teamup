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

  Future<void> likePost(String postId, String userId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    // Optimistic update
    final posts = currentState.posts;
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = posts[postIndex];
    final isLiked = post.likedByUserIds.contains(userId);

    // Update UI immediately
    final updatedPosts = [...posts];
    if (isLiked) {
      // Unlike
      updatedPosts[postIndex] = post.copyWith(
        likedByUserIds: post.likedByUserIds
            .where((id) => id != userId)
            .toList(),
        likesCount: post.likesCount - 1,
      );
    } else {
      // Like
      updatedPosts[postIndex] = post.copyWith(
        likedByUserIds: [...post.likedByUserIds, userId],
        likesCount: post.likesCount + 1,
      );
    }

    state = PostsState.loaded(updatedPosts);

    // Perform actual operation
    final result = isLiked
        ? await _postRepository.unlikePost(postId, userId)
        : await _postRepository.likePost(postId, userId);

    result.fold(
      (failure) {
        // Revert on error
        state = PostsState.loaded(posts);
      },
      (updatedPost) {
        // Update with server response
        final finalPosts = [...updatedPosts];
        finalPosts[postIndex] = updatedPost;
        state = PostsState.loaded(finalPosts);
      },
    );
  }

  Future<void> addComment(
    String postId,
    String content,
    String userId,
    String userName,
    String userAvatar,
  ) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    final result = await _postRepository.addComment(
      postId,
      content,
      userId,
      userName,
      userAvatar,
    );

    result.fold((failure) => state = PostsState.error(failure.message), (
      updatedPost,
    ) {
      final posts = currentState.posts;
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final updatedPosts = [...posts];
        updatedPosts[postIndex] = updatedPost;
        state = PostsState.loaded(updatedPosts);
      }
    });
  }
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, PostsState>((
  ref,
) {
  return PostsNotifier(ref.watch(postRepositoryProvider));
});
