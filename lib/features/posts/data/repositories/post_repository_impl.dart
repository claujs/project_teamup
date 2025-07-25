import 'package:dartz/dartz.dart';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;
  final UserRepository _userRepository;

  PostRepositoryImpl({
    required NetworkInfo networkInfo,
    required LocalStorage localStorage,
    required UserRepository userRepository,
  }) : _networkInfo = networkInfo,
       _localStorage = localStorage,
       _userRepository = userRepository;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      if (await _networkInfo.isConnected) {
        // Get real users from API first
        final usersResult = await _userRepository.getUsers(page: 1);
        final users = usersResult.fold(
          (failure) => <User>[],
          (usersList) => usersList,
        );

        // Generate fake posts with real users
        final posts = await _generateFakePostsWithRealUsers(users);
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

  Future<List<Post>> _generateFakePostsWithRealUsers(List<User> users) async {
    final faker = Faker();
    final posts = <Post>[];

    // If no users available, return empty list
    if (users.isEmpty) {
      return posts;
    }

    // Generate posts using real users from the API
    for (int i = 0; i < 20; i++) {
      final user = users[i % users.length];
      posts.add(
        Post(
          id: (i + 1).toString(),
          content: _generatePostContent(faker, user),
          authorId: user.id.toString(),
          authorName: '${user.firstName} ${user.lastName}',
          authorAvatar: user.avatar,
          createdAt: DateTime.now().subtract(
            Duration(hours: faker.randomGenerator.integer(168)),
          ),
          imageUrl: faker.randomGenerator.boolean()
              ? 'https://picsum.photos/400/300?random=$i'
              : null,
          likesCount: faker.randomGenerator.integer(100),
          tags: _generatePostTags(faker),
        ),
      );
    }

    return posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String _generatePostContent(Faker faker, User user) {
    final templates = [
      'Acabei de finalizar um projeto interessante! ${faker.lorem.sentence()}',
      'Compartilhando algumas insights sobre ${faker.lorem.word()}. ${faker.lorem.sentence()}',
      'Ótima sessão de brainstorming com a equipe hoje! ${faker.lorem.sentence()}',
      'Aprendendo novas tecnologias sempre é empolgante. ${faker.lorem.sentence()}',
      'Colaboração é a chave para o sucesso! ${faker.lorem.sentence()}',
      'Semana produtiva pela frente. ${faker.lorem.sentence()}',
      'Inovação acontece quando trabalhamos juntos. ${faker.lorem.sentence()}',
      'Reflexões sobre o trabalho em equipe. ${faker.lorem.sentence()}',
    ];

    return templates[faker.randomGenerator.integer(templates.length)];
  }

  List<String> _generatePostTags(Faker faker) {
    final allTags = [
      '#trabalho',
      '#equipe',
      '#inovação',
      '#desenvolvimento',
      '#tecnologia',
      '#colaboração',
      '#aprendizado',
      '#projeto',
      '#teamwork',
      '#produtividade',
    ];

    if (!faker.randomGenerator.boolean()) {
      return [];
    }

    final tagCount = faker.randomGenerator.integer(3) + 1;
    final selectedTags = <String>[];

    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[faker.randomGenerator.integer(allTags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }

    return selectedTags;
  }
}
