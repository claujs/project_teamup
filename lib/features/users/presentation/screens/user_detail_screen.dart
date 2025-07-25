import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import 'package:faker/faker.dart';

class UserDetailScreen extends ConsumerWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: ref.read(userRepositoryProvider).getUserById(int.parse(userId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Carregando perfil...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar perfil',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          return snapshot.data!.fold(
            (failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Usuário não encontrado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    failure.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
            (user) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: CachedNetworkImageProvider(user.avatar),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _generateJobTitle(user.id),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  _InfoCard(
                    icon: Icons.email_outlined,
                    title: 'E-mail',
                    content: user.email,
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.business_outlined,
                    title: 'Departamento',
                    content: _generateDepartment(user.id),
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Localização',
                    content: _generateLocation(user.id),
                  ),
                  const SizedBox(height: 16),

                  _InfoCard(
                    icon: Icons.info_outlined,
                    title: 'Sobre',
                    content: _generateBio(user.firstName),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userName:
                                      '${user.firstName} ${user.lastName}',
                                  userAvatar: user.avatar,
                                  userId: user.id.toString(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Conversar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidade em desenvolvimento',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text('Ligar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final isFavorite = ref
                          .watch(favoritesNotifierProvider)
                          .maybeWhen(
                            loaded: (favorites) =>
                                favorites.any((u) => u.id == user.id),
                            orElse: () => false,
                          );
                      return ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(favoritesNotifierProvider.notifier)
                              .toggleFavorite(user);
                        },
                        icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                        label: Text(
                          isFavorite
                              ? 'Remover dos Favoritos'
                              : 'Adicionar aos Favoritos',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFavorite ? Colors.yellow : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _generateJobTitle(int userId) {
    final positions = [
      'Desenvolvedor Frontend Sênior',
      'Desenvolvedor Backend Pleno',
      'Designer UX/UI',
      'Product Manager',
      'DevOps Engineer',
      'Data Scientist',
      'QA Engineer',
      'Tech Lead',
    ];
    return positions[userId % positions.length];
  }

  String _generateDepartment(int userId) {
    final departments = [
      'Tecnologia',
      'Produto',
      'Design',
      'Engenharia',
      'Dados',
      'Qualidade',
    ];
    return departments[userId % departments.length];
  }

  String _generateLocation(int userId) {
    final locations = [
      'São Paulo, SP',
      'Rio de Janeiro, RJ',
      'Belo Horizonte, MG',
      'Brasília, DF',
      'Remote',
      'Porto Alegre, RS',
    ];
    return locations[userId % locations.length];
  }

  String _generateBio(String firstName) {
    final faker = Faker();
    return faker.lorem.sentences(2).join(' ');
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
