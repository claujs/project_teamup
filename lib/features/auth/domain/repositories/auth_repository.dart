import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login(String email, String password);
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
}
