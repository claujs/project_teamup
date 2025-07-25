import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/local_user_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorage _localStorage;
  final LocalUserService _localUserService;

  AuthRepositoryImpl({required LocalStorage localStorage})
    : _localStorage = localStorage,
      _localUserService = LocalUserService();

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final userData = await _localUserService.getUser(email);
      if (userData != null && userData.isNotEmpty) {
        // Local user found, validate password
        if (await _localUserService.validateUser(email, password)) {
          await _localStorage.saveString(
            AppConstants.authTokenKey,
            AppStrings.localUserToken,
          );
          return Right(
            AuthUser(
              id: userData['id']?.toString() ?? '',
              email: userData['email']?.toString() ?? '',
              token: AppStrings.localUserToken,
              firstName: userData['firstName']?.toString() ?? '',
              lastName: userData['lastName']?.toString() ?? '',
            ),
          );
        }
      }

      // Demo user check
      if (email == AppStrings.demoEmail &&
          password == AppStrings.demoPassword) {
        await _localStorage.saveString(
          AppConstants.authTokenKey,
          AppStrings.demoToken,
        );
        return Right(
          AuthUser(
            id: AppStrings.demoUserId,
            email: email,
            token: AppStrings.demoToken,
            firstName: AppStrings.demoFirstName,
            lastName: AppStrings.demoLastName,
          ),
        );
      }

      // No valid credentials found
      return Left(AuthFailure(AppStrings.invalidCredentials));
    } catch (e) {
      return Left(ServerFailure('Erro interno: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register(
    String email,
    String fullName,
    String password,
  ) async {
    try {
      final existingUser = await _localUserService.getUser(email);
      if (existingUser != null && existingUser.isNotEmpty) {
        return Left(AuthFailure(AppStrings.userAlreadyExists));
      }

      // Create new user
      final registrationSuccess = await _localUserService.registerUser(
        email,
        fullName,
        password,
      );
      if (registrationSuccess) {
        final userData = await _localUserService.getUser(email);
        if (userData != null && userData.isNotEmpty) {
          await _localStorage.saveString(
            AppConstants.authTokenKey,
            AppStrings.localUserToken,
          );
          return Right(
            AuthUser(
              id: userData['id'],
              email: userData['email'],
              token: AppStrings.localUserToken,
              firstName: userData['firstName'],
              lastName: userData['lastName'],
            ),
          );
        }
      }

      return Left(AuthFailure('Erro ao cadastrar usuário'));
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
        // Garantir que o Map tem o tipo correto para Hive
        final map = Map<String, dynamic>.from(userData);
        final authUser = AuthUser.fromJson(map);
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
