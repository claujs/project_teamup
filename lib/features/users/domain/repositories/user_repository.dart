import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/advanced_filter.dart';

class PaginatedUsers {
  final List<User> users;
  final int currentPage;
  final int totalPages;
  final int total;

  const PaginatedUsers({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.total,
  });
}

abstract class UserRepository {
  Future<Either<Failure, PaginatedUsers>> getUsers({int page = 1});
  Future<Either<Failure, List<User>>> searchUsers(String query, {int page = 1});
  Future<Either<Failure, List<User>>> searchUsersAdvanced(
    AdvancedFilter filter, {
    int page = 1,
  });
  Future<Either<Failure, User>> getUserById(int id);
  Future<Either<Failure, List<User>>> getCachedUsers();
  Future<void> cacheUsers(List<User> users);
}
