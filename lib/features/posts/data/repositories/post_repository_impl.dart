import 'package:dartz/dartz.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  PostRepositoryImpl({
    required NetworkInfo networkInfo,
    required LocalStorage localStorage,
  }) : _networkInfo = networkInfo,
       _localStorage = localStorage;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      if (await _networkInfo.isConnected) {
        // Generate fake posts since we don't have a real API for posts
        final posts = _generateFakePosts();
        await cachePosts(posts);
        return Right(posts);
      } else {
        return getCachedPosts();
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getCachedPosts() async {
    try {
      final cachedData = await _localStorage.getObject<Map<String, dynamic>>(
        AppConstants.cachedPostsKey,
      );

      if (cachedData != null) {
        final posts = (cachedData['posts'] as List)
            .map((post) => Post.fromJson(post))
            .toList();
        return Right(posts);
      } else {
        return Left(CacheFailure('No cached posts found'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> cachePosts(List<Post> posts) async {
    try {
      final cacheData = {
        'posts': posts.map((post) => post.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _localStorage.saveObject(AppConstants.cachedPostsKey, cacheData);
    } catch (e) {
      debugPrint('Error caching posts: $e');
    }
  }

  List<Post> _generateFakePosts() {
    final faker = Faker();
    final posts = <Post>[];

    final authors = [
      {
        'name': 'Ana Silva',
        'avatar': 'https://reqres.in/img/faces/1-image.jpg',
      },
      {
        'name': 'Carlos Santos',
        'avatar': 'https://reqres.in/img/faces/2-image.jpg',
      },
      {
        'name': 'Maria Oliveira',
        'avatar': 'https://reqres.in/img/faces/3-image.jpg',
      },
      {
        'name': 'João Costa',
        'avatar': 'https://reqres.in/img/faces/4-image.jpg',
      },
      {
        'name': 'Fernanda Lima',
        'avatar': 'https://reqres.in/img/faces/5-image.jpg',
      },
    ];

    for (int i = 0; i < 20; i++) {
      final author = authors[i % authors.length];
      posts.add(
        Post(
          id: (i + 1).toString(),
          content: faker.lorem.sentences(2).join(' '),
          authorId: (i % authors.length + 1).toString(),
          authorName: author['name']!,
          authorAvatar: author['avatar']!,
          createdAt: DateTime.now().subtract(
            Duration(hours: faker.randomGenerator.integer(168)),
          ),
          imageUrl: faker.randomGenerator.boolean()
              ? 'https://picsum.photos/400/300?random=$i'
              : null,
          likesCount: faker.randomGenerator.integer(100),
          tags: faker.randomGenerator.boolean()
              ? [
                  '#trabalho',
                  '#equipe',
                  '#inovação',
                ].take(faker.randomGenerator.integer(3) + 1).toList()
              : [],
        ),
      );
    }

    return posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
