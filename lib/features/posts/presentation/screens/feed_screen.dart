import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/providers.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../posts_notifier.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with WidgetsBindingObserver {
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

  void _sharePost(BuildContext context, String content, String authorName) {
    final l10n = AppLocalizations.of(context)!;
    final shareText =
        '${l10n.sharedBy} $authorName ${l10n.onTeamUp}:\n\n$content';
    Share.share(shareText, subject: l10n.teamUpPost);
  }

  void _toggleComments(String postId) {
    final uiState = ref.read(uiStateProvider);
    final isExpanded = uiState.expandedPostIds.contains(postId);

    if (isExpanded) {
      ref.read(uiStateProvider.notifier).togglePostExpansion(postId);
      ref.read(commentControllersProvider.notifier).removeController(postId);
    } else {
      ref.read(uiStateProvider.notifier).togglePostExpansion(postId);
      // O controller será criado automaticamente quando necessário
    }
  }

  void _submitComment(String postId) {
    final authState = ref.read(authNotifierProvider);
    final controller = ref
        .read(commentControllersProvider.notifier)
        .getController(postId);

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
          ref.read(commentControllersProvider.notifier).clearController(postId);
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
    final uiState = ref.watch(uiStateProvider);

    return Scaffold(
      body: postsState.when(
        initial: () => const LoadingWidget(),
        loading: () => const LoadingWidget(),
        loaded: (posts) => RefreshIndicator(
          onRefresh: () async {
            if (mounted) {
              await _refreshFeed();
            }
          },
          child: posts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.noPostsFound,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : ResponsiveBuilder(
                  mobile: _buildMobileLayout(posts, authState, uiState),
                  tablet: _buildTabletLayout(posts, authState, uiState),
                ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorLoadingPosts,
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
                onPressed: () {
                  if (mounted) {
                    ref
                        .read(postsNotifierProvider.notifier)
                        .loadPosts(refresh: true);
                  }
                },
                child: Text(AppLocalizations.of(context)!.tryAgainButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    List<dynamic> posts,
    AuthState authState,
    UIState uiState,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          authState: authState,
          uiState: uiState,
          onLike: () => ref
              .read(postsNotifierProvider.notifier)
              .likePost(
                post.id,
                authState.maybeWhen(
                  authenticated: (user) => user.id,
                  orElse: () => '',
                ),
              ),
          onToggleComments: () => _toggleComments(post.id),
          onShare: () => _sharePost(context, post.content, post.authorName),
          onSubmitComment: () => _submitComment(post.id),
          commentController: ref
              .read(commentControllersProvider.notifier)
              .getController(post.id),
        );
      },
    );
  }

  Widget _buildTabletLayout(
    List<dynamic> posts,
    AuthState authState,
    UIState uiState,
  ) {
    final isLandscape = context.isLandscape;
    final crossAxisCount = isLandscape ? 2 : 1;

    return GridView.builder(
      padding: context.responsivePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isLandscape ? 0.8 : 1.2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          authState: authState,
          uiState: uiState,
          onLike: () => ref
              .read(postsNotifierProvider.notifier)
              .likePost(
                post.id,
                authState.maybeWhen(
                  authenticated: (user) => user.id,
                  orElse: () => '',
                ),
              ),
          onToggleComments: () => _toggleComments(post.id),
          onShare: () => _sharePost(context, post.content, post.authorName),
          onSubmitComment: () => _submitComment(post.id),
          commentController: ref
              .read(commentControllersProvider.notifier)
              .getController(post.id),
          isTablet: true,
        );
      },
    );
  }
}
