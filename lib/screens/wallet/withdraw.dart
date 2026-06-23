import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amountCtrl = TextEditingController();
  bool _success = false;
  String _successRef = '';

  double get _amount => double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  bool get _isFreelancer => ref.read(userProvider).role == UserRole.freelancer;
  double get _fee => _amount * 0.009;
  double get _netAmount => _amount - _fee;
  double get _ngnAmount => _netAmount * fxRate;
  double get _maxBalance => ref.read(userProvider).balance;
  bool get _valid => _amount > 0 && _amount <= _maxBalance;

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessView(isFreelancer: _isFreelancer, amount: _netAmount, ngnAmount: _ngnAmount, ref2: _successRef);

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
                  Text(_isFreelancer ? 'Withdraw to NGN' : 'Withdraw USD', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount to withdraw', style: TextStyle(fontSize: 13, color: Color(0xFFC9C6A6))),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('\$', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: _amountCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                                  decoration: const InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF5C5320), letterSpacing: -1),
                                    border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                                    fillColor: Colors.transparent, filled: false,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () { _amountCtrl.text = _maxBalance.toStringAsFixed(2); setState(() {}); },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                  child: const Text('Max', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Available: ${formatUSD(_maxBalance)}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF9C9A7C))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_amount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          _Row('Amount', formatUSD(_amount)),
                          _Row('Fee (0.9%)', '- ${formatUSD(_fee)}'),
                          if (_isFreelancer) _Row('\$1 = ₦${fxRate.toStringAsFixed(2)}', ''),
                          const Divider(height: 20, color: AppColors.border),
                          _Row('You receive', _isFreelancer ? formatNGN(_netAmount) : formatUSD(_netAmount), bold: true),
                        ]),
                      ),
                      const SizedBox(height: 14),
                    ],
                    // Bank
                    const Text('Payout account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 9),
                    Consumer(builder: (_, ref, __) {
                      final user = ref.watch(userProvider);
                      final account = user.payoutAccounts.where((a) => a.isDefault).firstOrNull;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_outlined, color: AppColors.greenDark, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(account?.bankName ?? 'No account', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                            const SizedBox(height: 1),
                            Text(account?.accountNumber ?? 'Add a payout account', style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
                          ])),
                        ]),
                      );
                    }),
                    if (!_isFreelancer) ...[
                      const SizedBox(height: 14),
                      const Row(children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.subText),
                        SizedBox(width: 6),
                        Text('No conversion · No hidden charges', style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
                      ]),
                    ],
                    const SizedBox(height: 24),
                    VButton(
                      label: 'Confirm withdrawal',
                      onTap: _valid ? _confirm : null,
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

  void _confirm() async {
    final ok = await showVConfirm(
      context,
      title: 'Withdraw ${formatUSD(_amount)}?',
      body: _isFreelancer
          ? 'You\'ll receive ${formatNGN(_netAmount)} in your GTBank account after the 0.9% fee.'
          : 'You\'ll receive ${formatUSD(_netAmount)} in your USD account after the 0.9% fee.',
      confirmLabel: 'Withdraw',
    );
    if (ok != true) return;

    ref.read(userProvider.notifier).withdraw(_amount);
    final refId = 'WDR-${DateTime.now().millisecondsSinceEpoch % 10000}';
    setState(() { _success = true; _successRef = refId; });
  }
}

class _SuccessView extends StatelessWidget {
  final bool isFreelancer;
  final double amount;
  final double ngnAmount;
  final String ref2;

  const _SuccessView({required this.isFreelancer, required this.amount, required this.ngnAmount, required this.ref2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.check, color: AppColors.greenDark, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('Withdrawal successful!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text(
                      isFreelancer
                          ? '${formatNGN(ngnAmount)} is on its way to your GTBank account.'
                          : '${formatUSD(amount)} is on its way to your USD account.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        _InfoRow('Reference', ref2),
                        _InfoRow('Amount', isFreelancer ? formatNGN(ngnAmount) : formatUSD(amount)),
                        _InfoRow('Est. arrival', '2–4 business hours'),
                        _InfoRow('Bank', 'GTBank • • • • 4502'),
                      ]),
                    ),
                  ],
                ),
              ),
              VButton(
                label: 'Done',
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _Row(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.5, color: bold ? AppColors.darkText : AppColors.subText2, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.darkText)),
      ],
    ),
  );
}

Widget _InfoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
  ]),
);
