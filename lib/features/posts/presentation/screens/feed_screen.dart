import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../posts_notifier.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with WidgetsBindingObserver {
  final Set<String> _expandedPosts = <String>{};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsNotifierProvider.notifier).loadPosts();
    });
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshFeed();
    }
  }

  Future<void> _refreshFeed() async {
    await ref.read(postsNotifierProvider.notifier).loadPosts(refresh: true);
  }

  void _sharePost(String content, String authorName) {
    final shareText = 'Compartilhado por $authorName no TeamUp:\n\n$content';
    Share.share(shareText, subject: 'Post do TeamUp');
  }

  void _toggleComments(String postId) {
    setState(() {
      if (_expandedPosts.contains(postId)) {
        _expandedPosts.remove(postId);
        _commentControllers[postId]?.dispose();
        _commentControllers.remove(postId);
      } else {
        _expandedPosts.add(postId);
        _commentControllers[postId] = TextEditingController();
      }
    });
  }

  void _submitComment(String postId) {
    final authState = ref.read(authNotifierProvider);
    final controller = _commentControllers[postId];

    if (controller == null) return;

    authState.when(
      initial: () {},
      loading: () {},
      authenticated: (user) {
        final content = controller.text.trim();
        if (content.isNotEmpty) {
          ref
              .read(postsNotifierProvider.notifier)
              .addComment(
                postId,
                content,
                user.id,
                '${user.firstName ?? ''} ${user.lastName ?? ''}',
                '',
              );
          controller.clear();
        }
      },
      unauthenticated: () {},
      error: (message) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: postsState.when(
        initial: () => const LoadingWidget(message: 'Carregando posts...'),
        loading: () => const LoadingWidget(message: 'Carregando posts...'),
        loaded: (posts) => RefreshIndicator(
          onRefresh: _refreshFeed,
          child: posts.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum post encontrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final currentUserId = authState.maybeWhen(
                      authenticated: (user) => user.id,
                      orElse: () => '',
                    );
                    final isLiked = post.likedByUserIds.contains(currentUserId);
                    final isExpanded = _expandedPosts.contains(post.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: CachedNetworkImageProvider(
                                    post.authorAvatar,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(post.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_vert, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              post.content,
                              style: const TextStyle(fontSize: 14),
                            ),

                            if (post.tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4,
                                children: post.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.1),
                                        side: BorderSide.none,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],

                            if (post.imageUrl != null) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: post.imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : null,
                                  ),
                                  onPressed: authState.maybeWhen(
                                    authenticated: (user) =>
                                        () => ref
                                            .read(
                                              postsNotifierProvider.notifier,
                                            )
                                            .likePost(post.id, user.id),
                                    orElse: () => null,
                                  ),
                                ),
                                Text('${post.likesCount}'),
                                const SizedBox(width: 16),

                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.comment
                                        : Icons.comment_outlined,
                                    color: isExpanded
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  onPressed: authState.maybeWhen(
                                    authenticated: (user) =>
                                        () => _toggleComments(post.id),
                                    orElse: () => null,
                                  ),
                                ),
                                Text('${post.comments.length}'),
                                const SizedBox(width: 16),

                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () =>
                                      _sharePost(post.content, post.authorName),
                                ),
                              ],
                            ),

                            if (isExpanded) ...[
                              const Divider(height: 24),

                              if (post.comments.isNotEmpty) ...[
                                const Text(
                                  'Comentários:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...post.comments.map(
                                  (comment) => Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(comment.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _commentControllers[post.id],
                                      maxLength: 100,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        hintText: 'Escreva um comentário...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        counterText: '',
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onSubmitted: (_) =>
                                          _submitComment(post.id),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () => _submitComment(post.id),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar posts',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(postsNotifierProvider.notifier)
                    .loadPosts(refresh: true),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}
