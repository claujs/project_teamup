import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/providers.dart';
import '../domain/entities/user.dart';
import '../domain/entities/advanced_filter.dart';
import '../domain/repositories/user_repository.dart';

part 'users_notifier.freezed.dart';

@freezed
class UsersState with _$UsersState {
  const factory UsersState.initial() = _Initial;
  const factory UsersState.loading() = _Loading;
  const factory UsersState.loaded({
    required List<User> users,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(0) int currentPage,
    @Default(0) int totalPages,
  }) = _Loaded;
  const factory UsersState.error(String message) = _Error;
}

class UsersNotifier extends StateNotifier<UsersState> {
  final UserRepository _userRepository;
  int _currentPage = 1;
  int _totalPages = 0;
  final List<User> _allUsers = [];

  UsersNotifier(this._userRepository) : super(const UsersState.initial());

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _totalPages = 0;
      _allUsers.clear();
    }

    state = const UsersState.loading();

    final result = await _userRepository.getUsers(page: _currentPage);
    result.fold((failure) => state = UsersState.error(failure.message), (
      paginatedUsers,
    ) {
      _allUsers.addAll(paginatedUsers.users);
      _totalPages = paginatedUsers.totalPages;
      _currentPage++;

      state = UsersState.loaded(
        users: List.from(_allUsers),
        hasReachedEnd: _currentPage > _totalPages,
        currentPage: paginatedUsers.currentPage,
        totalPages: _totalPages,
      );
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers(refresh: true);
      return;
    }

    state = const UsersState.loading();

    final result = await _userRepository.searchUsers(query);
    result.fold(
      (failure) => state = UsersState.error(failure.message),
      (users) => state = UsersState.loaded(users: users, hasReachedEnd: true),
    );
  }

  Future<void> searchUsersAdvanced(AdvancedFilter filter) async {
    if (filter.isEmpty) {
      await loadUsers(refresh: true);
      return;
    }

    state = const UsersState.loading();

    final result = await _userRepository.searchUsersAdvanced(filter);
    result.fold(
      (failure) => state = UsersState.error(failure.message),
      (users) => state = UsersState.loaded(users: users, hasReachedEnd: true),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! _Loaded || currentState.isLoadingMore) {
      return;
    }

    if (_currentPage > _totalPages && _totalPages > 0) {
      return;
    }

    state = currentState.copyWith(isLoadingMore: true);

    final result = await _userRepository.getUsers(page: _currentPage);

    result.fold(
      (failure) {
        state = currentState.copyWith(isLoadingMore: false);
      },
      (paginatedUsers) {
        _allUsers.addAll(paginatedUsers.users);
        _currentPage++;

        state = UsersState.loaded(
          users: List.from(_allUsers),
          isLoadingMore: false,
          hasReachedEnd: _currentPage > _totalPages,
          currentPage: paginatedUsers.currentPage,
          totalPages: _totalPages,
        );
      },
    );
  }

  void updatePaginationInfo(int totalPages) {
    _totalPages = totalPages;
  }
}

final usersNotifierProvider = StateNotifierProvider<UsersNotifier, UsersState>((
  ref,
) {
  return UsersNotifier(ref.watch(userRepositoryProvider));
});
