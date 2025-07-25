import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/app_strings.dart';
import '../storage/local_user_service.dart';

part 'credentials_provider.freezed.dart';

@freezed
class CredentialsState with _$CredentialsState {
  const factory CredentialsState({
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool hasSavedCredentials,
    @Default(false) bool isLoading,
  }) = _CredentialsState;
}

class CredentialsNotifier extends StateNotifier<CredentialsState> {
  final LocalUserService _localUserService;

  CredentialsNotifier(this._localUserService)
    : super(const CredentialsState()) {
    loadSavedCredentials();
  }

  Future<void> loadSavedCredentials() async {
    state = state.copyWith(isLoading: true);

    try {
      final credentials = await _localUserService.getSavedCredentials();
      if (credentials != null) {
        final email = credentials['email'];
        final password = credentials['password'];

        state = state.copyWith(
          email: email is String ? email : '',
          password: password is String ? password : '',
          hasSavedCredentials: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          email: '',
          password: '',
          hasSavedCredentials: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        email: '',
        password: '',
        hasSavedCredentials: false,
        isLoading: false,
      );
    }
  }

  Future<void> clearSavedCredentials() async {
    await _localUserService.clearSavedCredentials();
    state = state.copyWith(email: '', password: '', hasSavedCredentials: false);
  }

  void loadDemoCredentials() {
    state = state.copyWith(
      email: AppStrings.demoEmail,
      password: AppStrings.demoPassword,
    );
  }
}

final credentialsProvider =
    StateNotifierProvider<CredentialsNotifier, CredentialsState>((ref) {
      return CredentialsNotifier(LocalUserService());
    });
