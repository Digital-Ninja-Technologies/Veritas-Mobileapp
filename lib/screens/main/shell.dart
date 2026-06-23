import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../core/models.dart';
import 'home.dart';
import 'contracts.dart';
import 'activity.dart';
import 'profile.dart';
import '../contract/create.dart';
import '../wallet/withdraw.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    final user = ref.watch(userProvider);
    final hasUnread = ref.watch(hasUnreadNotifsProvider);

    final screens = [
      const HomeScreen(),
      const ContractsScreen(),
      const SizedBox(), // FAB placeholder
      const ActivityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: tab == 2 ? 0 : tab > 2 ? tab - 1 : tab,
        children: [screens[0], screens[1], screens[3], screens[4]],
      ),
      bottomNavigationBar: _BottomNav(
        currentTab: tab,
        hasUnread: hasUnread,
        onTab: (i) {
          if (i == 2) {
            // FAB action
            if (user.role == UserRole.client) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen()));
            } else {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const _FreelancerFab(),
              );
            }
          } else {
            ref.read(currentTabProvider.notifier).state = i;
          }
        },
        userRole: user.role,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentTab;
  final bool hasUnread;
  final ValueChanged<int> onTab;
  final UserRole userRole;

  const _BottomNav({
    required this.currentTab,
    required this.hasUnread,
    required this.onTab,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_outlined, filledIcon: Icons.home, label: 'Home', active: currentTab == 0, onTap: () => onTab(0)),
          _NavItem(icon: Icons.description_outlined, filledIcon: Icons.description, label: 'Escrows', active: currentTab == 1, onTap: () => onTab(1)),
          _FabItem(onTap: () => onTab(2), isClient: userRole == UserRole.client),
          _NavItem(icon: Icons.schedule_outlined, filledIcon: Icons.schedule, label: 'Activity', active: currentTab == 3, onTap: () => onTab(3)),
          _NavItem(icon: Icons.account_balance_wallet_outlined, filledIcon: Icons.account_balance_wallet, label: 'Wallet', active: currentTab == 4, onTap: () => onTab(4)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.filledIcon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? filledIcon : icon, color: active ? AppColors.dark : AppColors.subText, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: active ? AppColors.dark : AppColors.subText)),
          ],
        ),
      ),
    );
  }
}

class _FabItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool isClient;

  const _FabItem({required this.onTap, required this.isClient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.bg, width: 3),
                  boxShadow: [BoxShadow(color: AppColors.yellow.withOpacity(0.6), blurRadius: 18, offset: const Offset(0, 6))],
                ),
                child: Icon(
                  isClient ? Icons.add : Icons.upload_outlined,
                  color: AppColors.darkText,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreelancerFab extends StatelessWidget {
  const _FreelancerFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const Text('What would you like to do?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
          const SizedBox(height: 16),
          _SheetOption(
            icon: Icons.upload_file_outlined,
            label: 'Submit work',
            sub: 'Submit a milestone for client review',
            onTap: () {
              Navigator.pop(context);
              // Navigate to contracts to pick a contract
            },
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.payments_outlined,
            label: 'Request payment',
            sub: 'Send an invoice for new work',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _SheetOption({required this.icon, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.darkText, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.mutedText, size: 20),
          ],
        ),
      ),
    );
  }
}
