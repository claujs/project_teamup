import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/user_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  UserRepositoryImpl({
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
    required LocalStorage localStorage,
  }) : _apiClient = apiClient,
       _networkInfo = networkInfo,
       _localStorage = localStorage;

  @override
  Future<Either<Failure, List<User>>> getUsers({int page = 1}) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _apiClient.dio.get(
          AppConstants.usersEndpoint,
          queryParameters: {
            'page': page,
            'per_page': AppConstants.defaultPageSize,
          },
        );

        final userResponse = UserResponse.fromJson(response.data);
        final users = userResponse.data;

        // Cache users
        await cacheUsers(users);

        return Right(users);
      } else {
        return getCachedUsers();
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(
    String query, {
    int page = 1,
  }) async {
    try {
      final usersResult = await getUsers(page: page);
      return usersResult.fold((failure) => Left(failure), (users) {
        final filteredUsers = users
            .where(
              (user) =>
                  user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        return Right(filteredUsers);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _apiClient.dio.get(
          '${AppConstants.usersEndpoint}/$id',
        );
        final user = User.fromJson(response.data['data']);
        return Right(user);
      } else {
        final cachedUsersResult = await getCachedUsers();
        return cachedUsersResult.fold((failure) => Left(failure), (users) {
          try {
            final user = users.firstWhere((user) => user.id == id);
            return Right(user);
          } catch (e) {
            return Left(CacheFailure('User not found in cache'));
          }
        });
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getCachedUsers() async {
    try {
      final cachedData = await _localStorage.getObject<Map<String, dynamic>>(
        AppConstants.cachedUsersKey,
      );

      if (cachedData != null) {
        final users = (cachedData['users'] as List)
            .map((user) => User.fromJson(user))
            .toList();
        return Right(users);
      } else {
        return Left(CacheFailure('No cached users found'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> cacheUsers(List<User> users) async {
    try {
      final cacheData = {
        'users': users.map((user) => user.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _localStorage.saveObject(AppConstants.cachedUsersKey, cacheData);
    } catch (e) {
      // Log error but don't throw - caching is not critical
      print('Error caching users: $e');
    }
  }
}
