import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../../../core/providers.dart';

class PostCard extends StatelessWidget {
  final dynamic post;
  final AuthState authState;
  final UIState uiState;
  final VoidCallback onLike;
  final VoidCallback onToggleComments;
  final VoidCallback onShare;
  final VoidCallback onSubmitComment;
  final TextEditingController commentController;
  final bool isTablet;

  const PostCard({
    super.key,
    required this.post,
    required this.authState,
    required this.uiState,
    required this.onLike,
    required this.onToggleComments,
    required this.onShare,
    required this.onSubmitComment,
    required this.commentController,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => '',
    );
    final isLiked = post.likedByUserIds.contains(currentUserId);
    final isExpanded = uiState.expandedPostIds.contains(post.id);

    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 0 : 16),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isTablet ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 24 : 20,
                  backgroundImage: CachedNetworkImageProvider(
                    post.authorAvatar,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                      Text(
                        _formatDate(context, post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isTablet ? 14 : 12,
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
              style: TextStyle(fontSize: isTablet ? 16 : 14),
              maxLines: isTablet && !isExpanded ? 4 : null,
              overflow: isTablet && !isExpanded ? TextOverflow.ellipsis : null,
            ),

            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: post.tags
                    .map<Widget>(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(fontSize: isTablet ? 13 : 12),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        padding: isTablet
                            ? const EdgeInsets.symmetric(horizontal: 8)
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ],

            if (post.imageUrl != null && (!isTablet || isExpanded)) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  height: isTablet ? 250 : 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: isTablet ? 250 : 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: isTablet ? 250 : 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: authState.maybeWhen(
                    authenticated: (user) => onLike,
                    orElse: () => null,
                  ),
                ),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                const SizedBox(width: 16),

                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.comment : Icons.comment_outlined,
                    color: isExpanded
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: authState.maybeWhen(
                    authenticated: (user) => onToggleComments,
                    orElse: () => null,
                  ),
                ),
                Text(
                  '${post.comments.length}',
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
                const SizedBox(width: 16),

                IconButton(
                  icon: Icon(Icons.share_outlined, size: isTablet ? 28 : 24),
                  onPressed: onShare,
                ),
              ],
            ),

            if (isExpanded) ...[
              const Divider(height: 24),

              if (post.comments.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.commentsLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ MELHORADO: ListView.builder com altura máxima
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isTablet ? 400 : 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.authorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(context, comment.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isTablet ? 12 : 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comment.content,
                              style: TextStyle(fontSize: isTablet ? 15 : 13),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      maxLength: 100,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.writeCommentHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        counterText: '',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => onSubmitComment(),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, size: isTablet ? 28 : 24),
                    onPressed: onSubmitComment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat(AppStrings.dateFormat).format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${AppLocalizations.of(context)!.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${AppLocalizations.of(context)!.minutesAgo}';
    } else {
      return AppLocalizations.of(context)!.now;
    }
  }
}
