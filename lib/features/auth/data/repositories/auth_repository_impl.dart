import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  }) : _apiClient = apiClient,
       _localStorage = localStorage;

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      if (token != null) {
        final authUser = AuthUser(
          id: '1', // ReqRes doesn't return user ID, using dummy
          email: email,
          token: token,
        );

        // Save token and user data
        await _localStorage.saveString(AppConstants.authTokenKey, token);
        await _localStorage.saveObject(
          AppConstants.userDataKey,
          authUser.toJson(),
        );

        return Right(authUser);
      } else {
        return Left(AuthFailure('Invalid credentials'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return Left(AuthFailure('Invalid credentials'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final userData = await _localStorage.getObject<Map<String, dynamic>>(
        AppConstants.userDataKey,
      );

      if (userData != null) {
        final authUser = AuthUser.fromJson(userData);
        return Right(authUser);
      } else {
        return Right(null);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localStorage.delete(AppConstants.authTokenKey);
      await _localStorage.delete(AppConstants.userDataKey);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _localStorage.getString(AppConstants.authTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
