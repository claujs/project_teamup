import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/storage/local_storage.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/posts/data/repositories/post_repository_impl.dart';
import '../features/posts/domain/repositories/post_repository.dart';
import '../features/users/data/repositories/user_repository_impl.dart';
import '../features/users/domain/repositories/user_repository.dart';

// Core providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());
final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorageImpl(),
);

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(localStorage: ref.watch(localStorageProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    networkInfo: ref.watch(networkInfoProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    networkInfo: ref.watch(networkInfoProvider),
    localStorage: ref.watch(localStorageProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});
