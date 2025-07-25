import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../features/posts/presentation/screens/feed_screen.dart';
import '../../features/posts/presentation/posts_notifier.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/users/presentation/users_notifier.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import 'package:go_router/go_router.dart';
import '../../features/users/presentation/screens/favorites_screen.dart';
import '../../core/providers.dart';
import '../widgets/locale_toggle.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiStateProvider);

    final screens = [
      const FeedScreen(),
      const UsersScreen(),
      const FavoritesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Icon(Icons.people, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          const LocaleToggle(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(index: uiState.homeNavigationIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: uiState.homeNavigationIndex,
        onTap: (index) {
          ref.read(uiStateProvider.notifier).setHomeNavigationIndex(index);

          if (index == 0) {
            ref.read(postsNotifierProvider.notifier).loadPosts(refresh: true);
          } else if (index == 1) {
            ref.read(usersNotifierProvider.notifier).loadUsers(refresh: true);
          } else if (index == 2) {
            ref.read(favoritesNotifierProvider.notifier).loadFavorites();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.feedTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: AppStrings.teamTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: AppStrings.favoritesTab,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.logoutTitle),
          content: const Text(AppStrings.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authNotifierProvider.notifier).logout();
                context.go('/login');
              },
              child: Text(
                AppStrings.logoutButton,
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }
}
