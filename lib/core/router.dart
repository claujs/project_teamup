import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/users/presentation/screens/user_detail_screen.dart';
import '../shared/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        initial: () => false,
        loading: () => false,
        authenticated: (user) => true,
        unauthenticated: () => false,
        error: (message) => false,
      );

      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      if (isAuthenticated && isOnLoginPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id']!;
          return UserDetailScreen(userId: userId);
        },
      ),
    ],
  );
});
