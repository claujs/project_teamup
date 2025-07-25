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
import '../../core/utils/responsive_utils.dart';

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

    return ResponsiveBuilder(
      mobile: _MobileLayout(
        screens: screens,
        currentIndex: uiState.homeNavigationIndex,
      ),
      tablet: context.isLandscape
          ? _TabletLandscapeLayout(
              screens: screens,
              currentIndex: uiState.homeNavigationIndex,
            )
          : _TabletPortraitLayout(
              screens: screens,
              currentIndex: uiState.homeNavigationIndex,
            ),
    );
  }
}

// Layout para dispositivos móveis
class _MobileLayout extends ConsumerWidget {
  final List<Widget> screens;
  final int currentIndex;

  const _MobileLayout({required this.screens, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(uiStateProvider.notifier).setHomeNavigationIndex(index);
          // Atualizar dados ao trocar de aba
          switch (index) {
            case 0:
              ref.read(postsNotifierProvider.notifier).loadPosts();
              break;
            case 1:
              ref.read(usersNotifierProvider.notifier).loadUsers();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: AppStrings.feedTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppStrings.teamTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: AppStrings.favoritesTab,
          ),
        ],
      ),
    );
  }
}

// Layout para tablets em modo retrato
class _TabletPortraitLayout extends ConsumerWidget {
  final List<Widget> screens;
  final int currentIndex;

  const _TabletPortraitLayout({
    required this.screens,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
              child: const Icon(Icons.people, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          const LocaleToggle(),
          const SizedBox(width: 8),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
          ),
          const SizedBox(width: 8),
        ],
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveContainer(
        child: IndexedStack(index: currentIndex, children: screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        height: 80,
        onDestinationSelected: (index) {
          ref.read(uiStateProvider.notifier).setHomeNavigationIndex(index);
          // Atualizar dados ao trocar de aba
          switch (index) {
            case 0:
              ref.read(postsNotifierProvider.notifier).loadPosts();
              break;
            case 1:
              ref.read(usersNotifierProvider.notifier).loadUsers();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.feed_outlined),
            selectedIcon: Icon(Icons.feed),
            label: AppStrings.feedTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: AppStrings.teamTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: AppStrings.favoritesTab,
          ),
        ],
      ),
    );
  }
}

// Layout para tablets em modo paisagem
class _TabletLandscapeLayout extends ConsumerWidget {
  final List<Widget> screens;
  final int currentIndex;

  const _TabletLandscapeLayout({
    required this.screens,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(uiStateProvider.notifier).setHomeNavigationIndex(index);
              // Atualizar dados ao trocar de aba
              switch (index) {
                case 0:
                  ref.read(postsNotifierProvider.notifier).loadPosts();
                  break;
                case 1:
                  ref.read(usersNotifierProvider.notifier).loadUsers();
                  break;
              }
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
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
                    child: const Icon(
                      Icons.people,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const LocaleToggle(),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text(AppStrings.logoutButton),
                      onPressed: () {
                        _showLogoutDialog(context, ref);
                      },
                    ),
                  ],
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.feed_outlined),
                selectedIcon: Icon(Icons.feed),
                label: Text(AppStrings.feedTab),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text(AppStrings.teamTab),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: Text(AppStrings.favoritesTab),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: ResponsiveContainer(child: screens[currentIndex])),
        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutConfirmation),
        actions: <Widget>[
          TextButton(
            child: const Text(AppStrings.cancelButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(AppStrings.confirmButton),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context).pop();
              context.go('/login');
            },
          ),
        ],
      );
    },
  );
}
