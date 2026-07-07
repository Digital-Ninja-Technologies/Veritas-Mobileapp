import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../settings/kyc.dart';
import '../settings/payout_methods.dart';
import '../settings/settings.dart';
import '../settings/support_chat.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isClient = user.role == UserRole.client;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wallet & profile',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                      letterSpacing: -0.6)),
              const SizedBox(height: 16),
              // User card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                          color: AppColors.dark, shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                  color: AppColors.yellow,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(user.fullName.toString(),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText)),
                          const SizedBox(height: 2),
                          Text(
                              user.veritasTag != null
                                  ? '@${user.veritasTag}'
                                  : user.email.toLowerCase(),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.subText)),
                        ])),
                    _KycBadge(status: user.kycStatus),
                  ],
                ),
              ),

              // KYC card
              if (user.kycStatus == KycStatus.unverified) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const KycScreen())),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.dark, Color(0xFF3A340E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.credit_card_outlined,
                              color: AppColors.yellow, size: 23),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                              Text('Verify your identity',
                                  style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              SizedBox(height: 2),
                              Text('Required to withdraw & raise your limits',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFFC9C6A6))),
                            ])),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('Verify',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (user.kycStatus == KycStatus.inReview) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE3ECFF),
                              borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.pending_outlined,
                              color: AppColors.blue, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                            Text('Verification in review',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText)),
                            SizedBox(height: 2),
                            Text('We\'re checking your documents…',
                                style: TextStyle(
                                    fontSize: 12.5, color: AppColors.subText)),
                          ])),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE3ECFF),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('In review',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blue))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),
              const VSectionLabel('View as'),
              VRoleSwitcher(
                isClient: isClient,
                onFreelancer: () => ref
                    .read(userProvider.notifier)
                    .setRole(UserRole.freelancer),
                onClient: () =>
                    ref.read(userProvider.notifier).setRole(UserRole.client),
              ),

              const SizedBox(height: 22),
              const VSectionLabel('Payout method'),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PayoutMethodsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EF),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_outlined,
                            color: AppColors.greenDark, size: 20),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(_defaultBank(user),
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText)),
                            const SizedBox(height: 2),
                            Text(_defaultSub(user),
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.subText)),
                          ])),
                      const Icon(Icons.chevron_right,
                          color: AppColors.mutedText, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    VMenuItem(
                      icon: const Icon(Icons.shield_outlined,
                          color: AppColors.darkText, size: 20),
                      label: 'Identity & dispute protection',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const KycScreen())),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        _KycBadge(status: user.kycStatus),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.mutedText, size: 18),
                      ]),
                    ),
                    VMenuItem(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: AppColors.darkText, size: 20),
                      label: 'Talk to support',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SupportChatScreen())),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE6F6EC),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Online',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greenDark))),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.mutedText, size: 18),
                      ]),
                    ),
                    VMenuItem(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.darkText, size: 20),
                      label: 'Settings',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen())),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _defaultBank(UserModel user) {
  final def = user.payoutAccounts.where((a) => a.isDefault).firstOrNull;
  return def?.bankName ?? 'No account added';
}

String _defaultSub(UserModel user) {
  final def = user.payoutAccounts.where((a) => a.isDefault).firstOrNull;
  if (def == null) return 'Add a payout account';
  return '${def.accountNumber} · ${def.currency}';
}

class _KycBadge extends StatelessWidget {
  final KycStatus status;
  const _KycBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case KycStatus.verified:
        return const VStatusBadge(
            label: 'Verified', bg: Color(0xFFE8F5EF), fg: AppColors.greenDark);
      case KycStatus.inReview:
        return const VStatusBadge(
            label: 'In review', bg: Color(0xFFE3ECFF), fg: AppColors.blue);
      default:
        return const VStatusBadge(
            label: 'Unverified', bg: Color(0xFFFFF3CC), fg: AppColors.gold);
    }
  }
}
