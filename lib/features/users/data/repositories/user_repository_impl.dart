import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/services/job_info_service.dart';
import '../models/user_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/advanced_filter.dart';
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
  Future<Either<Failure, PaginatedUsers>> getUsers({int page = 1}) async {
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

        await cacheUsers(users);

        final paginatedUsers = PaginatedUsers(
          users: users,
          currentPage: userResponse.page,
          totalPages: userResponse.totalPages,
          total: userResponse.total,
        );

        return Right(paginatedUsers);
      } else {
        final cachedUsersResult = await getCachedUsers();
        return cachedUsersResult.fold(
          (failure) => Left(failure),
          (users) => Right(
            PaginatedUsers(
              users: users,
              currentPage: 1,
              totalPages: 1,
              total: users.length,
            ),
          ),
        );
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
      return usersResult.fold((failure) => Left(failure), (paginatedUsers) {
        final filteredUsers = paginatedUsers.users
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
  Future<Either<Failure, List<User>>> searchUsersAdvanced(
    AdvancedFilter filter, {
    int page = 1,
  }) async {
    try {
      if (filter.isEmpty) {
        final usersResult = await getUsers(page: page);
        return usersResult.fold(
          (failure) => Left(failure),
          (paginatedUsers) => Right(paginatedUsers.users),
        );
      }

      final usersResult = await getUsers(page: page);
      return usersResult.fold((failure) => Left(failure), (paginatedUsers) {
        final filteredUsers = paginatedUsers.users.where((user) {
          return _matchesAdvancedFilters(user, filter);
        }).toList();

        return Right(filteredUsers);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  bool _matchesAdvancedFilters(User user, AdvancedFilter filter) {
    if (filter.name?.trim().isNotEmpty == true) {
      final nameMatch = user.fullName.toLowerCase().contains(
        filter.name!.trim().toLowerCase(),
      );
      if (!nameMatch) return false;
    }
    if (filter.email?.trim().isNotEmpty == true) {
      final emailMatch = user.email.toLowerCase().contains(
        filter.email!.trim().toLowerCase(),
      );
      if (!emailMatch) return false;
    }
    if (filter.department?.trim().isNotEmpty == true) {
      final userDepartmentPt = JobInfoService.generateDepartmentWithoutContext(
        user.id,
        isPortuguese: true,
      ).toLowerCase();
      final userDepartmentEn = JobInfoService.generateDepartmentWithoutContext(
        user.id,
        isPortuguese: false,
      ).toLowerCase();

      final filterDepartment = filter.department!.trim().toLowerCase();
      final departmentMatch =
          userDepartmentPt.contains(filterDepartment) ||
          userDepartmentEn.contains(filterDepartment);
      if (!departmentMatch) return false;
    }
    if (filter.position?.trim().isNotEmpty == true) {
      final userPositionPt = JobInfoService.generateJobTitleWithoutContext(
        user.id,
        isPortuguese: true,
      ).toLowerCase();
      final userPositionEn = JobInfoService.generateJobTitleWithoutContext(
        user.id,
        isPortuguese: false,
      ).toLowerCase();

      final filterPosition = filter.position!.trim().toLowerCase();
      final positionMatch =
          userPositionPt.contains(filterPosition) ||
          userPositionEn.contains(filterPosition);
      if (!positionMatch) return false;
    }

    return true;
  }

  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _apiClient.dio.get(
          '${AppConstants.usersEndpoint}/$id',
        );
        try {
          final user = User.fromJson(response.data['data']);
          return Right(user);
        } catch (e) {
          debugPrint('Error parsing user from API response: $e');
          debugPrint('Response data: ${response.data}');
          return Left(ServerFailure('Failed to parse user data: $e'));
        }
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
        final usersList = cachedData['users'] as List;
        final users = <User>[];

        for (int i = 0; i < usersList.length; i++) {
          try {
            final userData = usersList[i];
            final map = userData is Map<String, dynamic>
                ? userData
                : Map<String, dynamic>.from(userData as Map);
            final user = User.fromJson(map);
            users.add(user);
          } catch (e) {
            debugPrint('Error parsing user at index $i: $e');
            debugPrint('User data: ${usersList[i]}');
            continue;
          }
        }

        return Right(users);
      } else {
        return Left(CacheFailure('No cached users found'));
      }
    } catch (e) {
      debugPrint('Error getting cached users: $e');
      await _localStorage.delete(AppConstants.cachedUsersKey);
      return Left(CacheFailure('Cache corrupted, cleared: ${e.toString()}'));
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
      debugPrint('Error caching users: $e');
    }
  }
}
