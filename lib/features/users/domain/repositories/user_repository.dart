import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers({int page = 1});
  Future<Either<Failure, List<User>>> searchUsers(String query, {int page = 1});
  Future<Either<Failure, User>> getUserById(int id);
  Future<Either<Failure, List<User>>> getCachedUsers();
  Future<void> cacheUsers(List<User> users);
}
