import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final _amountCtrl = TextEditingController();
  int _methodIndex = 0;
  bool _success = false;
  String _successRef = '';

  final _methods = [
    _PayMethod('Visa / Mastercard', '1.5% fee', Icons.credit_card_outlined, Color(0xFFE8F0FF)),
    _PayMethod('Bank transfer (ACH)', 'Free · 1–3 days', Icons.account_balance_outlined, Color(0xFFE8F5EF)),
    _PayMethod('USDC (crypto)', 'Free · instant', Icons.currency_bitcoin, Color(0xFFFFF3CC)),
  ];

  double get _amount => double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  double get _fee => _methodIndex == 0 ? _amount * 0.015 : 0;
  double get _total => _amount + _fee;

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessView(amount: _amount, ref2: _successRef);

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
                  const Text('Add funds', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                          const Text('Amount', style: TextStyle(fontSize: 13, color: Color(0xFFC9C6A6))),
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
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [500, 1000, 5000].map((v) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () { _amountCtrl.text = v.toString(); setState(() {}); },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                  child: Text('\$$v', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.yellow)),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Payment method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 10),
                    ...List.generate(_methods.length, (i) {
                      final m = _methods[i];
                      final active = _methodIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _methodIndex = i),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: active ? AppColors.dark : AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: m.bg, borderRadius: BorderRadius.circular(11)),
                                  child: Icon(m.icon, color: AppColors.darkText, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                                  const SizedBox(height: 2),
                                  Text(m.sub, style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                                ])),
                                Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? AppColors.dark : AppColors.border, width: 2)),
                                  child: active
                                      ? Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle))
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_amount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          _Row('Amount', formatUSD(_amount)),
                          if (_fee > 0) _Row('Card processing (1.5%)', formatUSD(_fee)),
                          const Divider(height: 20, color: AppColors.border),
                          _Row('You pay', formatUSD(_total), bold: true),
                          _Row('Est. arrival', _methodIndex == 0 ? 'Instant' : _methodIndex == 1 ? '1–3 business days' : 'Within minutes'),
                        ]),
                      ),
                      const SizedBox(height: 14),
                    ],
                    VButton(
                      label: 'Add funds',
                      onTap: _amount > 0 ? _confirm : null,
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
      title: 'Add ${formatUSD(_amount)}?',
      body: _fee > 0
          ? 'A ${formatUSD(_fee)} card processing fee applies. ${formatUSD(_amount)} will be added to your Veritas balance.'
          : '${formatUSD(_amount)} will be added to your Veritas balance with no fees.',
      confirmLabel: 'Add funds',
    );
    if (ok != true) return;

    ref.read(userProvider.notifier).creditBalance(_amount);
    final refId = 'TOP-${DateTime.now().millisecondsSinceEpoch % 10000}';
    setState(() { _success = true; _successRef = refId; });
  }
}

class _SuccessView extends StatelessWidget {
  final double amount;
  final String ref2;
  const _SuccessView({required this.amount, required this.ref2});

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
                    const Text('Funds added!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text(
                      '${formatUSD(amount)} has been added to your Veritas balance.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        _InfoRow('Reference', ref2),
                        _InfoRow('Amount', formatUSD(amount)),
                        _InfoRow('Status', 'Completed'),
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

class _PayMethod {
  final String name, sub;
  final IconData icon;
  final Color bg;
  const _PayMethod(this.name, this.sub, this.icon, this.bg);
}

Widget _Row(String label, String value, {bool bold = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 13.5, color: bold ? AppColors.darkText : AppColors.subText2, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(value, style: TextStyle(fontSize: 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.darkText)),
    ],
  ),
);

Widget _InfoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
  ]),
);
