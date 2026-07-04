import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../contract/detail.dart';
import '../contract/create.dart';

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider);
    final user = ref.watch(userProvider);
    // The role switcher on Home filters which contracts to emphasize, but
    // whether the CURRENT user is client or freelancer is per-contract —
    // the backend is symmetric, you can be either depending on the deal.
    final isClient = user.role == UserRole.client;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshContracts(ref),
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Escrow contracts', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.6)),
                    const SizedBox(height: 4),
                    Text(
                      isClient ? '${contracts.length} active contracts' : 'Contracts where you\'re the freelancer',
                      style: const TextStyle(fontSize: 14, color: AppColors.subText2),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (contracts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(24)),
                        child: const Icon(Icons.description_outlined, size: 40, color: AppColors.subText),
                      ),
                      const SizedBox(height: 16),
                      const Text('No contracts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                      const SizedBox(height: 8),
                      const Text('Create your first escrow contract\nto get started.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.subText2, height: 1.5)),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(14)),
                          child: const Text('Create contract', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i == contracts.length) return const SizedBox(height: 110);
                      final c = contracts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ContractListCard(contract: c, user: user),
                      );
                    },
                    childCount: contracts.length + 1,
                  ),
                ),
              ),
          ],
          ),
        ),
      ),
      floatingActionButton: isClient
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEscrowScreen())),
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.darkText,
              icon: const Icon(Icons.add),
              label: const Text('New escrow', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}

class _ContractListCard extends StatelessWidget {
  final EscrowContract contract;
  final UserModel user;

  const _ContractListCard({required this.contract, required this.user});

  @override
  Widget build(BuildContext context) {
    final isClient = contract.isClientFor(user.id);
    final party = isClient ? contract.freelancerName : contract.clientName;
    final badge = contract.statusBadge;
    final pct = contract.progressPct;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContractDetailScreen(contractId: contract.id))),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(contract.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.darkText))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(contract.project, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  const SizedBox(height: 2),
                  Text(party, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
                ])),
                _BadgeFor(badge),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Contract value', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                  const SizedBox(height: 1),
                  Text(formatUSD(contract.totalAmount), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.4)),
                  const SizedBox(height: 1),
                  Text('≈ ${formatNGN(contract.totalAmount)}', style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${(pct * 100).round()}% · ${contract.completedMilestones}/${contract.milestones.length} milestones',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: AppColors.lightBg,
                        valueColor: AlwaysStoppedAnimation(_barColor(badge)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _BadgeFor(String badge) {
  Color bg, fg;
  switch (badge) {
    case 'Complete': bg = AppColors.completeBadgeBg; fg = AppColors.completeBadgeFg; break;
    case 'In dispute': bg = const Color(0xFFFCE2E0); fg = AppColors.redDark; break;
    case 'In review': bg = const Color(0xFFFFF3CC); fg = AppColors.gold; break;
    case 'Awaiting': bg = const Color(0xFFF0EDFF); fg = const Color(0xFF6E3FCF); break;
    default: bg = AppColors.activeBadgeBg; fg = AppColors.greenDark;
  }
  return VStatusBadge(label: badge, bg: bg, fg: fg);
}

Color _barColor(String badge) {
  switch (badge) {
    case 'Complete': return AppColors.blue;
    case 'In dispute': return AppColors.red;
    case 'Awaiting': return const Color(0xFF6E3FCF);
    default: return AppColors.greenDark;
  }
}
