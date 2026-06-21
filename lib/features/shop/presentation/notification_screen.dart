import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/providers/api_notification_provider.dart';
import '../../../core/models/api_notification.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationProvider.notifier).markAllAsRead(),
            child: const Text('Mark All Read', style: TextStyle(color: AppTheme.gold, fontSize: 12)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
            color: AppTheme.gold,
            backgroundColor: AppTheme.darkGray,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (ctx, i) => _NotificationCard(
                notification: notifications[i],
                onRead: () => ref.read(notificationProvider.notifier).markAsRead(notifications[i].id),
                onDelete: () => ref.read(notificationProvider.notifier).delete(notifications[i].id),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.gray))),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  const _NotificationCard({required this.notification, required this.onRead, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) onRead();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? AppTheme.darkGray : AppTheme.darkGray.withAlpha(230),
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead ? null : Border.all(color: AppTheme.gold.withAlpha(50)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: _typeColor(notification.type).withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Icon(_typeIcon(notification.type), color: _typeColor(notification.type), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title, style: TextStyle(color: Colors.white, fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
                        ),
                        if (!notification.isRead)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message, style: const TextStyle(color: AppTheme.gray, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(_timeAgo(notification.createdAt!), style: const TextStyle(color: AppTheme.gray, fontSize: 10)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    if (type.startsWith('order')) return AppTheme.gold;
    if (type.startsWith('payment')) return Colors.green;
    if (type.contains('review')) return Colors.blue;
    return AppTheme.gray;
  }

  IconData _typeIcon(String type) {
    if (type.startsWith('order')) return Icons.shopping_bag_outlined;
    if (type.startsWith('payment')) return Icons.payment;
    if (type.contains('review')) return Icons.star_outline;
    if (type.contains('stock')) return Icons.inventory_2_outlined;
    return Icons.notifications_outlined;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}
