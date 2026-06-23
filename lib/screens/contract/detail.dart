import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../settings/support_chat.dart';
import 'submit_work.dart';
import 'request_changes.dart';
import 'dispute.dart';

class ContractDetailScreen extends ConsumerWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider);
    final user = ref.watch(userProvider);
    final contract = contracts.firstWhere((c) => c.id == contractId);
    final isClient = user.role == UserRole.client;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const VBackButton(),
                    const SizedBox(width: 14),
                    const Text('Contract', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54, height: 54,
                          decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(contract.initials, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: AppColors.darkText))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(contract.project, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.4)),
                          const SizedBox(height: 2),
                          Text(isClient ? contract.freelancerName : contract.clientName, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Dark value card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('Total in escrow', style: TextStyle(fontSize: 12.5, color: Color(0xFFC9C6A6))),
                                const SizedBox(height: 4),
                                Text(formatUSD(contract.totalAmount), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.8)),
                                const SizedBox(height: 3),
                                Text('≈ ${formatNGN(contract.totalAmount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.yellow)),
                              ]),
                              _BadgeFor(contract.statusBadge),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(Icons.verified_outlined, color: AppColors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                isClient ? 'Your funds are locked until work is approved' : 'Funds released when client approves your work',
                                style: const TextStyle(fontSize: 12, color: Color(0xFFC9C6A6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Milestones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                    const SizedBox(height: 4),
                    Text(
                      '${contract.completedMilestones} of ${contract.milestones.length} completed',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.subText),
                    ),
                    const SizedBox(height: 16),
                    // Milestones
                    ...contract.milestones.asMap().entries.map((e) {
                      final i = e.key;
                      final m = e.value;
                      final isLast = i == contract.milestones.length - 1;
                      return _MilestoneRow(
                        milestone: m,
                        isLast: isLast,
                        isClient: isClient,
                        contractId: contractId,
                        ref: ref,
                      );
                    }),
                    const SizedBox(height: 8),
                    // Support card
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportChatScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.16), shape: BoxShape.circle),
                              child: const Icon(Icons.chat_bubble_outline, color: AppColors.yellow, size: 20),
                            ),
                            const SizedBox(width: 13),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                              Text('Have a problem with this contract?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                              SizedBox(height: 2),
                              Text('Chat with support or raise a dispute', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                            ])),
                            const Icon(Icons.chevron_right, color: AppColors.subText, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DisputeScreen(contract: contract))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(16)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_outlined, color: AppColors.redDark, size: 17),
                            SizedBox(width: 8),
                            Text('Raise a dispute', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.redDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isLast;
  final bool isClient;
  final String contractId;
  final WidgetRef ref;

  const _MilestoneRow({
    required this.milestone,
    required this.isLast,
    required this.isClient,
    required this.contractId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final (dotBg, dotFg, showAction, actionLabel, actionBg, actionFg, showReject) = _milestoneConfig();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 3)),
                  child: milestone.status == MilestoneStatus.released
                      ? const Icon(Icons.check, size: 9, color: Colors.white)
                      : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(milestone.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          const SizedBox(height: 6),
                          _MilestoneBadge(milestone.status),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(formatUSD(milestone.amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                          const SizedBox(height: 2),
                          Text(formatNGN(milestone.amount), style: const TextStyle(fontSize: 11, color: AppColors.subText)),
                        ]),
                      ],
                    ),
                    // Delivery note
                    if (milestone.deliveryNote != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFBF9E8), border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Icon(Icons.description_outlined, color: AppColors.gold, size: 13),
                            const SizedBox(width: 7),
                            const Text('DELIVERY NOTE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.4)),
                          ]),
                          const SizedBox(height: 6),
                          Text(milestone.deliveryNote!, style: const TextStyle(fontSize: 13, color: Color(0xFF5C5320), height: 1.5)),
                          if (milestone.deliveryLink != null) ...[
                            const SizedBox(height: 9),
                            Row(children: [
                              const Icon(Icons.link, color: AppColors.blue, size: 13),
                              const SizedBox(width: 6),
                              Expanded(child: Text(milestone.deliveryLink!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.blue), overflow: TextOverflow.ellipsis)),
                            ]),
                          ],
                        ]),
                      ),
                    ],
                    // Changes requested note
                    if (milestone.changeNote != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFCE7DD), border: Border.all(color: const Color(0xFFF3CBB6)), borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Icon(Icons.replay, color: AppColors.orange, size: 13),
                            const SizedBox(width: 7),
                            const Text('CHANGES REQUESTED', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.orange, letterSpacing: 0.4)),
                          ]),
                          const SizedBox(height: 6),
                          Text(milestone.changeNote!, style: const TextStyle(fontSize: 13, color: Color(0xFF7A3A12), height: 1.5)),
                        ]),
                      ),
                    ],
                    // Dispute note
                    if (milestone.disputeRef != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFCE2E0), border: Border.all(color: const Color(0xFFF0C0BB)), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.warning_amber, color: AppColors.redDark, size: 13),
                          const SizedBox(width: 7),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Dispute ${milestone.disputeRef}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.redDark, letterSpacing: 0.4)),
                            const SizedBox(height: 4),
                            Text(_disputeStatusLabel(milestone.disputeStatus), style: const TextStyle(fontSize: 13, color: Color(0xFF8A2B22), height: 1.4)),
                          ])),
                        ]),
                      ),
                    ],
                    if (showAction) ...[
                      const SizedBox(height: 13),
                      GestureDetector(
                        onTap: () => _doAction(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(color: actionBg, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_actionIcon(), color: actionFg, size: 15),
                              const SizedBox(width: 7),
                              Text(actionLabel, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: actionFg)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (showReject) ...[
                      const SizedBox(height: 9),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RequestChangesScreen(contractId: contractId, milestone: milestone))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.replay, color: AppColors.orange, size: 15),
                              SizedBox(width: 7),
                              Text('Request changes', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.orange)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, bool, String, Color, Color, bool) _milestoneConfig() {
    switch (milestone.status) {
      case MilestoneStatus.released:
        return (AppColors.greenDark, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
      case MilestoneStatus.submitted:
      case MilestoneStatus.inReview:
        if (!isClient) {
          return (AppColors.gold, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
        }
        return (AppColors.gold, Colors.white, true, 'Release funds', AppColors.yellow, AppColors.darkText, true);
      case MilestoneStatus.changesRequested:
        if (isClient) return (AppColors.orange, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
        return (AppColors.orange, Colors.white, true, 'Resubmit work', AppColors.lightBg, AppColors.darkText, false);
      case MilestoneStatus.inProgress:
        if (isClient) return (AppColors.blue, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
        return (AppColors.blue, Colors.white, true, 'Submit work', AppColors.dark, Colors.white, false);
      case MilestoneStatus.inDispute:
        return (AppColors.red, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
      default:
        if (!isClient) return (AppColors.border, Colors.white, true, 'Submit work', AppColors.dark, Colors.white, false);
        return (AppColors.border, Colors.white, false, '', Colors.transparent, Colors.transparent, false);
    }
  }

  IconData _actionIcon() {
    switch (milestone.status) {
      case MilestoneStatus.submitted:
      case MilestoneStatus.inReview:
        return isClient ? Icons.lock_open_outlined : Icons.check;
      case MilestoneStatus.changesRequested:
        return Icons.upload_outlined;
      default:
        return Icons.upload_file_outlined;
    }
  }

  void _doAction(BuildContext context) async {
    if (milestone.status == MilestoneStatus.submitted || milestone.status == MilestoneStatus.inReview) {
      if (isClient) {
        final ok = await showVConfirm(context, title: 'Release ${formatUSD(milestone.amount)}?', body: 'This releases funds to the freelancer. The action can\'t be recalled once confirmed.', confirmLabel: 'Release');
        if (ok == true) {
          ref.read(contractsProvider.notifier).updateMilestone(contractId, milestone.id, milestone.copyWith(status: MilestoneStatus.released));
          if (context.mounted) showVToast(context, 'Funds released!');
        }
      }
    } else {
      // Submit work
      Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitWorkScreen(contractId: contractId, milestone: milestone)));
    }
  }
}

String _disputeStatusLabel(DisputeStatus? status) {
  switch (status) {
    case DisputeStatus.underReview: return 'Under review · Funds stay locked while we review the case.';
    case DisputeStatus.resolved: return 'Resolved · Funds have been returned to the client.';
    default: return 'Dispute opened · Our team will review within 48 hours.';
  }
}

class _MilestoneBadge extends StatelessWidget {
  final MilestoneStatus status;
  const _MilestoneBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _badge();
    return VStatusBadge(label: label, bg: bg, fg: fg);
  }

  (String, Color, Color) _badge() {
    switch (status) {
      case MilestoneStatus.released: return ('Released', AppColors.activeBadgeBg, AppColors.greenDark);
      case MilestoneStatus.submitted: return ('Submitted', const Color(0xFFFFF3CC), AppColors.gold);
      case MilestoneStatus.inReview: return ('In review', const Color(0xFFFFF3CC), AppColors.gold);
      case MilestoneStatus.changesRequested: return ('Changes req.', const Color(0xFFFCE7DD), AppColors.orange);
      case MilestoneStatus.inProgress: return ('In progress', AppColors.completeBadgeBg, AppColors.blue);
      case MilestoneStatus.inDispute: return ('In dispute', const Color(0xFFFCE2E0), AppColors.redDark);
      case MilestoneStatus.refunded: return ('Refunded', const Color(0xFFE3ECFF), AppColors.blue);
      default: return ('Pending', AppColors.lightBg, AppColors.subText);
    }
  }
}

Widget _BadgeFor(String badge) {
  Color bg, fg;
  switch (badge) {
    case 'Complete': bg = AppColors.completeBadgeBg; fg = AppColors.completeBadgeFg; break;
    case 'In dispute': bg = const Color(0xFFFCE2E0); fg = AppColors.redDark; break;
    case 'In review': bg = const Color(0xFFFFF3CC); fg = AppColors.gold; break;
    default: bg = AppColors.activeBadgeBg; fg = AppColors.greenDark;
  }
  return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)));
}
