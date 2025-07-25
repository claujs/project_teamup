import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.when(
          initial: () => const LoadingWidget(),
          loading: () => const LoadingWidget(),
          loaded: (favorites) => favorites.isEmpty
              ? const Center(child: Text('Nenhum favorito adicionado.'))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final user = favorites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            user.avatar,
                          ),
                        ),
                        title: Text('${user.firstName} ${user.lastName}'),
                        subtitle: Text(user.email),
                        onTap: () => context.push('/user/${user.id}'),
                      ),
                    );
                  },
                ),
          error: (message) => Center(child: Text('Erro: $message')),
        ),
      ),
    );
  }
}
