import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/providers.dart';
import '../../../core/storage/local_user_service.dart';
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
  final LocalUserService _localUserService;

  AuthNotifier(this._authRepository)
    : _localUserService = LocalUserService(),
      super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    try {
      // Verificar se há credenciais salvas
      final hasSavedCredentials = await _localUserService.hasSavedCredentials();
      if (hasSavedCredentials) {
        final credentials = await _localUserService.getSavedCredentials();
        if (credentials != null) {
          final email = credentials['email'];
          final password = credentials['password'];

          if (email is String && password is String) {
            // Tentar fazer login automático
            final result = await _authRepository.login(email, password);
            result.fold((failure) => _proceedWithNormalAuthCheck(), (user) {
              state = AuthState.authenticated(user);
              return;
            });
          } else {
            _proceedWithNormalAuthCheck();
          }
        } else {
          _proceedWithNormalAuthCheck();
        }
      } else {
        _proceedWithNormalAuthCheck();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      _proceedWithNormalAuthCheck();
    }
  }

  Future<void> _proceedWithNormalAuthCheck() async {
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

  Future<void> register(String email, String fullName, String password) async {
    state = const AuthState.loading();

    final result = await _authRepository.register(email, fullName, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _localUserService.clearSavedCredentials();
    state = const AuthState.unauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
