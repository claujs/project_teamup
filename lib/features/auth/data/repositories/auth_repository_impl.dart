import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
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
      // Primeiro, verificar se é um usuário cadastrado localmente
      final isLocalUser = await _localUserService.validateUser(email, password);
      if (isLocalUser) {
        final userData = await _localUserService.getUser(email);
        if (userData != null) {
          const localToken = 'local_user_token';
          final authUser = AuthUser(
            id: userData['id']?.toString() ?? '',
            email: userData['email']?.toString() ?? '',
            token: localToken,
            firstName: userData['firstName']?.toString() ?? '',
            lastName: userData['lastName']?.toString() ?? '',
          );

          // Salvar credenciais para login automático
          await _localUserService.saveCredentials(email, password);

          // Save token and user data
          await _localStorage.saveString(AppConstants.authTokenKey, localToken);
          await _localStorage.saveObject(
            AppConstants.userDataKey,
            authUser.toJson(),
          );

          return Right(authUser);
        }
      }

      // Check for mock credentials (eve.holt@reqres.in) - também local, sem API
      if (email == 'eve.holt@reqres.in' && password == 'cityslicka') {
        const mockToken = 'demo_user_token';
        final authUser = AuthUser(
          id: 'demo_user',
          email: email,
          token: mockToken,
          firstName: 'Eve',
          lastName: 'Holt',
        );

        // Salvar credenciais para login automático
        await _localUserService.saveCredentials(email, password);

        // Save token and user data
        await _localStorage.saveString(AppConstants.authTokenKey, mockToken);
        await _localStorage.saveObject(
          AppConstants.userDataKey,
          authUser.toJson(),
        );

        return Right(authUser);
      }

      // Se não encontrou usuário local nem demo, retornar erro
      return Left(
        AuthFailure(
          'Credenciais inválidas. Cadastre-se primeiro ou use as credenciais de demonstração.',
        ),
      );
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
      // Verificar se o usuário já existe localmente
      final userExists = await _localUserService.userExists(email);
      if (userExists) {
        return Left(AuthFailure('Usuário já cadastrado com este e-mail'));
      }

      // Registrar usuário localmente
      final registrationSuccess = await _localUserService.registerUser(
        email,
        fullName,
        password,
      );

      if (registrationSuccess) {
        // Criar AuthUser para o usuário registrado
        final userData = await _localUserService.getUser(email);
        if (userData != null) {
          const localToken = 'local_user_token';
          final authUser = AuthUser(
            id: userData['id'],
            email: userData['email'],
            token: localToken,
            firstName: userData['firstName'],
            lastName: userData['lastName'],
          );

          // Salvar credenciais para login automático
          await _localUserService.saveCredentials(email, password);

          // Save token and user data
          await _localStorage.saveString(AppConstants.authTokenKey, localToken);
          await _localStorage.saveObject(
            AppConstants.userDataKey,
            authUser.toJson(),
          );

          return Right(authUser);
        } else {
          return Left(AuthFailure('Erro ao recuperar dados do usuário'));
        }
      } else {
        return Left(AuthFailure('Erro ao cadastrar usuário'));
      }
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
