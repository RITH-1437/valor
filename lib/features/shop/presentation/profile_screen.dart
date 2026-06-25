import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_order_provider.dart';
import '../../../core/providers/api_wishlist_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();
  bool _isAvatarLoading = false;

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _avatarOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              _avatarOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose From Gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (ref.read(authProvider).user?.avatar != null)
                _avatarOption(
                  icon: Icons.delete_outline,
                  label: 'Remove Photo',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeAvatar();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.gold),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null) return;
      if (!mounted) return;

      setState(() => _isAvatarLoading = true);

      await ref.read(authProvider.notifier).uploadAvatar(file);

      if (mounted) {
        setState(() => _isAvatarLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAvatarLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isAvatarLoading = true);
    try {
      await ref.read(authProvider.notifier).removeAvatar();
      if (mounted) {
        setState(() => _isAvatarLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo removed'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAvatarLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove photo: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final orders = ref.watch(orderProvider);
    final wishlist = ref.watch(wishlistProvider);

    final user = auth.user;
    final orderCount = orders.value?.length ?? 0;
    final wishlistCount = wishlist.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.gray),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAvatarOptions,
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.gold, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withAlpha(40),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _isAvatarLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.gold,
                                strokeWidth: 3,
                              ),
                            )
                          : user?.avatar != null
                              ? Hero(
                                  tag: 'profile_avatar',
                                  child: CachedNetworkImage(
                                    imageUrl: user!.avatar!,
                                    fit: BoxFit.cover,
                                    placeholder: (ctx, url) => Container(
                                      color: AppTheme.darkGray,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.gold,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (ctx, url, err) =>
                                        _defaultAvatar(),
                                  ),
                                )
                              : _defaultAvatar(),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppTheme.black,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppTheme.gray, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _statCard('Orders', '$orderCount'),
                const SizedBox(width: 12),
                _statCard('Wishlist', '$wishlistCount'),
              ],
            ),
            const SizedBox(height: 32),
            _menuItem(
              context,
              Icons.receipt_long_outlined,
              'My Orders',
              AppTheme.gold,
              () => context.push('/orders'),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              Icons.favorite_outline,
              'Wishlist',
              Colors.redAccent,
              () => context.push('/wishlist'),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              Icons.location_on_outlined,
              'Shipping Addresses',
              AppTheme.gray,
              () => context.push('/addresses'),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              Icons.notifications_outlined,
              'Notifications',
              Colors.blue,
              () => context.push('/notifications'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(authProvider.notifier).logout();
                  } catch (_) {}
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppTheme.darkGray,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: AppTheme.gray,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppTheme.gray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.gray, size: 20),
          ],
        ),
      ),
    );
  }
}
