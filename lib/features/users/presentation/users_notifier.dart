import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/providers.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/user_repository.dart';

part 'users_notifier.freezed.dart';

@freezed
class UsersState with _$UsersState {
  const factory UsersState.initial() = _Initial;
  const factory UsersState.loading() = _Loading;
  const factory UsersState.loaded(List<User> users) = _Loaded;
  const factory UsersState.error(String message) = _Error;
}

class UsersNotifier extends StateNotifier<UsersState> {
  final UserRepository _userRepository;
  int _currentPage = 1;
  final List<User> _allUsers = [];

  UsersNotifier(this._userRepository) : super(const UsersState.initial());

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _allUsers.clear();
    }

    state = const UsersState.loading();

    final result = await _userRepository.getUsers(page: _currentPage);
    result.fold((failure) => state = UsersState.error(failure.message), (
      users,
    ) {
      _allUsers.addAll(users);
      state = UsersState.loaded(List.from(_allUsers));
      _currentPage++;
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
      (users) => state = UsersState.loaded(users),
    );
  }

  Future<void> loadMore() async {
    if (state is! _Loaded) return;

    final result = await _userRepository.getUsers(page: _currentPage);

    result.fold(
      (failure) {}, // Don't change state on error for load more
      (users) {
        _allUsers.addAll(users);
        state = UsersState.loaded(List.from(_allUsers));
        _currentPage++;
      },
    );
  }
}

final usersNotifierProvider = StateNotifierProvider<UsersNotifier, UsersState>((
  ref,
) {
  return UsersNotifier(ref.watch(userRepositoryProvider));
});
