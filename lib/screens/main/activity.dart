import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../wallet/transaction_receipt.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);

    final grouped = <String, List<TransactionModel>>{};
    for (final tx in txs) {
      final key = _dateLabel(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text('Activity', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.6)),
              ),
            ),
            if (txs.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.subText),
                      SizedBox(height: 16),
                      Text('No transactions yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                      final entries = grouped.entries.toList();
                      if (i == entries.length) return const SizedBox(height: 110);
                      final entry = entries[i];
                      return _TxGroup(date: entry.key, items: entry.value);
                    },
                    childCount: grouped.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return DateFormat('EEEE, d MMMM').format(dt);
}

class _TxGroup extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;

  const _TxGroup({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(date.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.subText, letterSpacing: 0.6)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return _TxRow(tx: e.value, isLast: isLast);
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionModel tx;
  final bool isLast;

  const _TxRow({required this.tx, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final (iconBg, iconFg, icon) = _iconFor(tx.kind);
    final amtColor = tx.isCredit ? AppColors.greenDark : AppColors.darkText;
    final amtPrefix = tx.isCredit ? '+' : '-';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionReceiptScreen(tx: tx))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconFg, size: 18),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tx.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  const SizedBox(height: 2),
                  Text(tx.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                ])),
                Text('$amtPrefix${formatUSD(tx.amount)}', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: amtColor)),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, thickness: 1, color: Color(0xFFF1EFD6), indent: 16),
        ],
      ),
    );
  }
}

(Color, Color, IconData) _iconFor(String kind) {
  switch (kind) {
    case 'release': return (const Color(0xFFE8F5EF), AppColors.greenDark, Icons.lock_open_outlined);
    case 'withdraw': return (const Color(0xFFF0F4FF), AppColors.blue, Icons.download_outlined);
    case 'topup': return (const Color(0xFFFFF9E0), AppColors.gold, Icons.add_circle_outline);
    case 'fund': return (const Color(0xFFFFF0F0), AppColors.redDark, Icons.lock_outline);
    default: return (AppColors.lightBg, AppColors.subText, Icons.swap_horiz);
  }
}
