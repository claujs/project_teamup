import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/utils/responsive_utils.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/posts/presentation/screens/feed_screen.dart';
import '../../features/users/presentation/screens/favorites_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../shared/widgets/locale_toggle.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(uiStateProvider).homeNavigationIndex;
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, ref, currentIndex, l10n),
      tablet: _buildTabletLayout(context, ref, currentIndex, l10n),
      desktop: _buildDesktopLayout(context, ref, currentIndex, l10n),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          const LocaleToggle(),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text(l10n.logoutButton),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(uiStateProvider.notifier).setHomeNavigationIndex(index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.feed),
            label: l10n.feedTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.teamTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.favoritesTab,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => ref
                .read(uiStateProvider.notifier)
                .setHomeNavigationIndex(index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LocaleToggle(),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout),
                        tooltip: l10n.logoutButton,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.feed),
                label: Text(l10n.feedTab),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.people),
                label: Text(l10n.teamTab),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.favorite),
                label: Text(l10n.favoritesTab),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildBody(currentIndex)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => ref
                .read(uiStateProvider.notifier)
                .setHomeNavigationIndex(index),
            labelType: NavigationRailLabelType.all,
            minWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
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
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const LocaleToggle(),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showLogoutDialog(context, ref),
                          icon: const Icon(Icons.logout),
                          label: Text(l10n.logoutButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.feed),
                label: Text(l10n.feedTab),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.people),
                label: Text(l10n.teamTab),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.favorite),
                label: Text(l10n.favoritesTab),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildBody(currentIndex)),
        ],
      ),
    );
  }

  Widget _buildBody(int currentIndex) {
    final screens = [
      const FeedScreen(),
      const UsersScreen(),
      const FavoritesScreen(),
    ];
    return IndexedStack(index: currentIndex, children: screens);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
  }
}
