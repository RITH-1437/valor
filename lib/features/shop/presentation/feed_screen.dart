import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/api_post.dart';
import '../../../core/repositories/social_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) => SocialRepository());

final feedProvider = FutureProvider<List<PostModel>>((ref) async {
  ref.watch(authProvider);
  return ref.read(socialRepositoryProvider).getFeed();
});

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('VALOR Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.gold),
            onPressed: () => _showCreatePost(context, ref),
          ),
        ],
      ),
      body: feedAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(
              icon: Icons.dynamic_feed_outlined,
              title: 'Your feed is empty',
              subtitle: 'Follow people to see their style posts here',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(feedProvider),
            color: AppTheme.gold,
            backgroundColor: AppTheme.darkGray,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (ctx, i) => _PostCard(post: posts[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }

  void _showCreatePost(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkGray,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CreatePostSheet(),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final PostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppTheme.darkGray, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.black,
                  backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
                  child: post.userAvatar == null ? const Icon(Icons.person, color: AppTheme.gray, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(post.userName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    if (post.createdAt != null)
                      Text(DateFormat('MMM d, yyyy • h:mm a').format(post.createdAt!), style: const TextStyle(color: AppTheme.gray, fontSize: 11)),
                  ]),
                ),
              ],
            ),
          ),

          // Content
          if (post.content != null && post.content!.isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(post.content!, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5))),

          // Image
          if (post.image != null)
            CachedNetworkImage(
              imageUrl: post.image!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(height: 300, color: AppTheme.black, child: const Center(child: CircularProgressIndicator(color: AppTheme.gold))),
              errorWidget: (ctx, url, err) => Container(height: 300, color: AppTheme.black, child: const Icon(Icons.image, color: AppTheme.gray)),
            ),

          // Style tags
          if (post.styleTags != null && post.styleTags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 6,
                children: post.styleTags!.split(',').map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.gold.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                  child: Text(tag.trim(), style: const TextStyle(color: AppTheme.gold, fontSize: 11)),
                )).toList(),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await ref.read(socialRepositoryProvider).toggleLike(post.id);
                    ref.invalidate(feedProvider);
                  },
                  child: Row(children: [
                    Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.redAccent : AppTheme.gray, size: 20),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}', style: TextStyle(color: post.isLiked ? Colors.redAccent : AppTheme.gray, fontSize: 13)),
                  ]),
                ),
                const SizedBox(width: 20),
                Row(children: [
                  const Icon(Icons.chat_bubble_outline, color: AppTheme.gray, size: 20),
                  const SizedBox(width: 4),
                  Text('${post.commentsCount}', style: const TextStyle(color: AppTheme.gray, fontSize: 13)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.gray, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Create Post', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _contentCtrl,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Share your style...',
              hintStyle: TextStyle(color: AppTheme.gray),
              filled: true,
              fillColor: AppTheme.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Style tags (comma separated)',
              hintStyle: TextStyle(color: AppTheme.gray),
              filled: true,
              fillColor: AppTheme.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold, foregroundColor: AppTheme.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.black))
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (_contentCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(socialRepositoryProvider).createPost(
        content: _contentCtrl.text.trim(),
        styleTags: _tagsCtrl.text.trim().isNotEmpty ? _tagsCtrl.text.trim() : null,
      );
      ref.invalidate(feedProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {}
    setState(() => _isLoading = false);
  }
}
