import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionModel tx;
  const TransactionReceiptScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final color = isCredit ? AppColors.greenDark : AppColors.redDark;
    final bgColor = isCredit ? const Color(0xFFE8F5EF) : const Color(0xFFFCE2E0);
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

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
                  const Text('Transaction receipt', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(22)),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${isCredit ? '+' : '–'} ${formatUSD(tx.amount)}',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color, letterSpacing: -1),
                    ),
                    const SizedBox(height: 6),
                    Text(tx.title, style: const TextStyle(fontSize: 15, color: AppColors.subText2, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greenDark)),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        if (tx.reference != null) _InfoRow('Reference', tx.reference!),
                        _InfoRow('Date', _formatDate(tx.date)),
                        _InfoRow('Type', isCredit ? 'Credit' : 'Debit'),
                        _InfoRow('Category', tx.kind),
                        if (tx.subtitle.isNotEmpty) _InfoRow('Description', tx.subtitle),
                        if (tx.counterparty != null) _InfoRow(isCredit ? 'From' : 'To', tx.counterparty!),
                        if (tx.method != null) _InfoRow('Method', tx.method!),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.subText, size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Questions about this transaction? Contact our support team.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.subText2, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    VButton(
                      label: 'Done',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

Widget _InfoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5.5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    Flexible(child: Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText), textAlign: TextAlign.right)),
  ]),
);
