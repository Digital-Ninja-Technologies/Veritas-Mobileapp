import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const VBackButton(),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Notifications', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText))),
                  if (unread > 0)
                    GestureDetector(
                      onTap: () => ref.read(notificationsProvider.notifier).markAllRead(),
                      child: const Text('Mark all read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notifications.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length,
                      itemBuilder: (_, i) => _NotifCard(notif: notifications[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFFFFCE0),
        border: Border.all(color: notif.isRead ? AppColors.border : const Color(0xFFE8E300)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _iconBg(notif.kind), borderRadius: BorderRadius.circular(12)),
            child: Icon(_iconData(notif.kind), color: _iconColor(notif.kind), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(notif.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText))),
                    if (!notif.isRead)
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(notif.subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.subText2, height: 1.4)),
                const SizedBox(height: 5),
                Text(_timeAgo(notif.time), style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconData(String kind) {
    switch (kind) {
      case 'withdraw': return Icons.attach_money;
      case 'milestone': return Icons.task_alt;
      case 'dispute': return Icons.gavel_outlined;
      case 'escrow': return Icons.lock_outline;
      case 'kyc': return Icons.verified_outlined;
      default: return Icons.info_outline;
    }
  }

  Color _iconBg(String kind) {
    switch (kind) {
      case 'withdraw': return const Color(0xFFE8F5EF);
      case 'milestone': return const Color(0xFFFFF3CC);
      case 'dispute': return const Color(0xFFFCE2E0);
      case 'kyc': return const Color(0xFFE8F5EF);
      default: return const Color(0xFFE8F0FF);
    }
  }

  Color _iconColor(String kind) {
    switch (kind) {
      case 'withdraw': return AppColors.greenDark;
      case 'milestone': return AppColors.gold;
      case 'dispute': return AppColors.redDark;
      case 'kyc': return AppColors.greenDark;
      default: return AppColors.blue;
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.notifications_outlined, color: AppColors.subText, size: 30),
      ),
      const SizedBox(height: 16),
      const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      const SizedBox(height: 6),
      const Text('You\'ll see updates on payments and escrows here.', style: TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    ]),
  );
}
