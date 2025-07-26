import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/favorites_skeleton.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../domain/entities/user.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesNotifierProvider.notifier).loadFavorites();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshFavorites();
    }
  }

  Future<void> _refreshFavorites() async {
    await ref.read(favoritesNotifierProvider.notifier).loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesNotifierProvider);
    final isTablet = context.isTabletOrLarger;

    return Scaffold(
      body: favoritesState.when(
        initial: () => Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
          child: const FavoritesSkeleton(),
        ),
        loading: () => Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
          child: const FavoritesSkeleton(),
        ),
        loaded: (users) => users.isEmpty
            ? _buildEmptyState(context, isTablet)
            : RefreshIndicator(
                onRefresh: _refreshFavorites,
                child: ResponsiveBuilder(
                  mobile: _buildMobileLayout(users),
                  tablet: _buildTabletLayout(users),
                ),
              ),
        error: (message) => _buildErrorState(context, message, isTablet),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: isTablet ? 100 : 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            AppLocalizations.of(context)!.noFavoritesAdded,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando seus usuários favoritos',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar para a aba de usuários
              ref.read(uiStateProvider.notifier).setHomeNavigationIndex(1);
            },
            icon: Icon(Icons.people, size: isTablet ? 24 : 20),
            label: Text(
              'Ver Usuários',
              style: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
            style: isTablet
                ? ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar favoritos',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: isTablet ? 28 : null),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: isTablet
                ? ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  )
                : null,
            onPressed: () =>
                ref.read(favoritesNotifierProvider.notifier).loadFavorites(),
            child: Text(
              AppLocalizations.of(context)!.tryAgainButton,
              style: TextStyle(fontSize: isTablet ? 18 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<dynamic> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _FavoriteCard(
          user: user,
          onTap: () => context.push('/user/${user.id}'),
          onRemove: () {
            ref
                .read(favoritesNotifierProvider.notifier)
                .toggleFavorite(user.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Removido dos favoritos'),
                action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: () {
                    ref
                        .read(favoritesNotifierProvider.notifier)
                        .toggleFavorite(user.id);
                  },
                ),
              ),
            );
          },
          isTablet: false,
        );
      },
    );
  }

  Widget _buildTabletLayout(List<dynamic> users) {
    final isLandscape = context.isLandscape;
    final crossAxisCount = isLandscape ? 3 : 2;

    return ResponsiveContainer(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isLandscape ? 1.2 : 1.1,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _FavoriteCard(
            user: user,
            onTap: () => context.push('/user/${user.id}'),
            onRemove: () {
              ref
                  .read(favoritesNotifierProvider.notifier)
                  .toggleFavorite(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Removido dos favoritos'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Desfazer',
                    onPressed: () {
                      ref
                          .read(favoritesNotifierProvider.notifier)
                          .toggleFavorite(user.id);
                    },
                  ),
                ),
              );
            },
            isTablet: true,
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool isTablet;

  const _FavoriteCard({
    required this.user,
    required this.onTap,
    required this.onRemove,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'avatar_${user.id}',
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: CachedNetworkImageProvider(
                          user.avatar,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.getJobInfo(context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Hero(
          tag: 'avatar_${user.id}',
          child: CircleAvatar(
            radius: 28,
            backgroundImage: CachedNetworkImageProvider(user.avatar),
          ),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Text(
              user.getJobInfo(context),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        onTap: onTap,
      ),
    );
  }
}
