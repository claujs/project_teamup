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
import '../features/users/presentation/favorites_notifier.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/presentation/chat_notifier.dart';
export 'providers/ui_state_provider.dart';
export 'providers/credentials_provider.dart';
export 'providers/comment_controllers_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());
final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorageImpl(),
);

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

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      return FavoritesNotifier(ref.watch(localStorageProvider));
    });

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((
  ref,
) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});
