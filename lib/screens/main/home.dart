import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../contract/detail.dart';
import '../wallet/fx_detail.dart';
import '../wallet/withdraw.dart';
import '../wallet/add_funds.dart';
import 'shell.dart';
import '../settings/notifications.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final contracts = ref.watch(contractsProvider);
    final hasUnread = ref.watch(hasUnreadNotifsProvider);
    final isClient = user.role == UserRole.client;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App bar
                    Row(
                      children: [
                        const VeritasLogo(),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                          child: Stack(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(Icons.notifications_outlined, color: AppColors.darkText, size: 20),
                              ),
                              if (hasUnread)
                                Positioned(
                                  top: 9,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Role switcher
                    VRoleSwitcher(
                      isClient: isClient,
                      onFreelancer: () => ref.read(userProvider.notifier).setRole(UserRole.freelancer),
                      onClient: () => ref.read(userProvider.notifier).setRole(UserRole.client),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_greeting()}, ',
                      style: const TextStyle(fontSize: 15, color: AppColors.subText2),
                    ).also((w) => Row(children: [
                      Text('${_greeting()}, ', style: const TextStyle(fontSize: 15, color: AppColors.subText2)),
                      Text(user.firstName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    ])),
                    const SizedBox(height: 12),
                    // Balance card
                    _BalanceCard(user: user, isClient: isClient, ref: ref),
                    const SizedBox(height: 14),
                    // Stats strip
                    _StatsStrip(user: user, contracts: contracts),
                    const SizedBox(height: 14),
                    // Multi-currency teaser
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FxDetailScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.yellow, Color(0xFFFFF49B)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hold money in 6 currencies', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                                  const SizedBox(height: 3),
                                  const Text('NGN · KES · GHS · XOF · USD · EUR', style: TextStyle(fontSize: 12.5, color: Color(0xFF5C5320))),
                                ],
                              ),
                            ),
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: AppColors.dark, shape: BoxShape.circle, border: Border.all(color: AppColors.yellow, width: 2)),
                              child: const Center(child: Text('₦', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w800, fontSize: 16))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isClient ? 'Your contracts' : 'Active contracts', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.3)),
                        GestureDetector(
                          onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                          child: const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.subText2)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == contracts.length) return const SizedBox(height: 110);
                    final c = contracts[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _ContractCard(contract: c, user: user),
                    );
                  },
                  childCount: contracts.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _Also<T extends Widget> on T {
  Widget also(Widget Function(T w) builder) => builder(this);
}

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

class _BalanceCard extends StatelessWidget {
  final UserModel user;
  final bool isClient;
  final WidgetRef ref;

  const _BalanceCard({required this.user, required this.isClient, required this.ref});

  @override
  Widget build(BuildContext context) {
    final balance = user.balance;
    final ngnBalance = balance * fxRate;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isClient ? 'Client wallet' : 'Available balance', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFC9C6A6))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    const Text('USD Wallet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE9E7CF))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatUSD(balance), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2, height: 0.95)),
              const SizedBox(width: 8),
              const Padding(padding: EdgeInsets.only(bottom: 5), child: Text('USD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF9C9A7C)))),
            ],
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FxDetailScreen())),
            child: Row(
              children: [
                Text('≈ ${formatNGN(balance)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.yellow)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Text('\$1 = ₦${fxRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.yellow)),
                      const SizedBox(width: 3),
                      const Icon(Icons.chevron_right, color: AppColors.yellow, size: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_outlined, color: AppColors.darkText, size: 17),
                        const SizedBox(width: 8),
                        Text(isClient ? 'Withdraw' : 'Withdraw to NGN', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isClient) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFundsScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FxDetailScreen()));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      border: Border.all(color: Colors.white.withOpacity(0.16)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isClient ? Icons.add : Icons.currency_exchange, color: Colors.white, size: 17),
                        const SizedBox(width: 8),
                        Text(isClient ? 'Add funds' : 'Convert', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final UserModel user;
  final List<EscrowContract> contracts;

  const _StatsStrip({required this.user, required this.contracts});

  @override
  Widget build(BuildContext context) {
    final inEscrow = contracts.fold<double>(0, (sum, c) => sum + c.totalAmount);
    final earned = contracts.fold<double>(0, (sum, c) => sum + c.completedAmount);

    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.lock_outline,
          iconColor: const Color(0xFFC9A800),
          label: 'In escrow',
          value: formatUSD(inEscrow),
          sub: '${contracts.length} active',
        )),
        const SizedBox(width: 11),
        Expanded(child: _StatCard(
          icon: Icons.attach_money,
          iconColor: AppColors.greenDark,
          label: user.role == UserRole.freelancer ? 'Total earned' : 'Total released',
          value: formatUSD(earned),
          sub: 'This month',
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _StatCard({required this.icon, required this.iconColor, required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.subText)),
          ]),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.4)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
        ],
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final EscrowContract contract;
  final UserModel user;

  const _ContractCard({required this.contract, required this.user});

  @override
  Widget build(BuildContext context) {
    final isClient = user.role == UserRole.client;
    final party = isClient ? contract.freelancerName : contract.clientName;
    final badge = contract.statusBadge;
    final pct = contract.progressPct;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ContractDetailScreen(contractId: contract.id),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(13)),
                  child: Center(child: Text(contract.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.darkText))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(contract.project, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(party, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(formatUSD(contract.totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                  const SizedBox(height: 4),
                  _BadgeFor(badge),
                ]),
              ],
            ),
            const SizedBox(height: 13),
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${contract.completedMilestones}/${contract.milestones.length} milestones', style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
                Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.subText2)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 7,
                  backgroundColor: AppColors.lightBg,
                  valueColor: AlwaysStoppedAnimation(_barColor(badge)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _BadgeFor(String badge) {
  Color bg, fg;
  switch (badge) {
    case 'Complete':
      bg = AppColors.completeBadgeBg; fg = AppColors.completeBadgeFg;
      break;
    case 'In dispute':
      bg = const Color(0xFFFCE2E0); fg = AppColors.redDark;
      break;
    case 'In review':
      bg = const Color(0xFFFFF3CC); fg = AppColors.gold;
      break;
    default:
      bg = AppColors.activeBadgeBg; fg = AppColors.greenDark;
  }
  return VStatusBadge(label: badge, bg: bg, fg: fg);
}

Color _barColor(String badge) {
  switch (badge) {
    case 'Complete': return AppColors.blue;
    case 'In dispute': return AppColors.red;
    default: return AppColors.greenDark;
  }
}
