import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/providers.dart';
import '../domain/entities/auth_user.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_notifier.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AuthUser user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => state = const AuthState.unauthenticated(),
        (user) => state = user != null
            ? AuthState.authenticated(user)
            : const AuthState.unauthenticated(),
      );
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    final result = await _authRepository.login(email, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
