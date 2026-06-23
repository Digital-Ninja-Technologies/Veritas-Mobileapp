import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class PayoutMethodsScreen extends ConsumerStatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  ConsumerState<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends ConsumerState<PayoutMethodsScreen> {
  bool _adding = false;
  final _bankCtrl = TextEditingController();
  final _acctCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final accounts = user.payoutAccounts;

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
                  const Expanded(child: Text('Payout methods', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText))),
                  GestureDetector(
                    onTap: () => setState(() => _adding = !_adding),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(10)),
                      child: const Text('+ Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_adding) ...[
                      _AddBankForm(
                        bankCtrl: _bankCtrl,
                        acctCtrl: _acctCtrl,
                        nameCtrl: _nameCtrl,
                        onSave: _saveAccount,
                        onCancel: () => setState(() => _adding = false),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (accounts.isEmpty && !_adding)
                      _EmptyState(onAdd: () => setState(() => _adding = true))
                    else
                      ...accounts.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AccountCard(
                          account: a,
                          onSetDefault: () => ref.read(userProvider.notifier).setDefaultPayout(a.id),
                          onDelete: () => _confirmDelete(a),
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAccount() {
    if (_bankCtrl.text.isEmpty || _acctCtrl.text.isEmpty || _nameCtrl.text.isEmpty) return;
    final account = PayoutAccount(
      id: 'acc${DateTime.now().millisecondsSinceEpoch}',
      bankName: _bankCtrl.text.trim(),
      accountNumber: _acctCtrl.text.trim(),
      accountName: _nameCtrl.text.trim(),
      currency: 'NGN',
      isDefault: ref.read(userProvider).payoutAccounts.isEmpty,
    );
    ref.read(userProvider.notifier).addPayoutAccount(account);
    _bankCtrl.clear(); _acctCtrl.clear(); _nameCtrl.clear();
    setState(() => _adding = false);
    showVToast(context, 'Account added');
  }

  void _confirmDelete(PayoutAccount a) async {
    final ok = await showVConfirm(context, title: 'Remove account?', body: '${a.bankName} • ${a.accountNumber} will be removed.', confirmLabel: 'Remove');
    if (ok == true && mounted) ref.read(userProvider.notifier).removePayoutAccount(a.id);
  }
}

class _AccountCard extends StatelessWidget {
  final PayoutAccount account;
  final VoidCallback onSetDefault, onDelete;

  const _AccountCard({required this.account, required this.onSetDefault, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: account.isDefault ? AppColors.dark : AppColors.border, width: account.isDefault ? 1.5 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_outlined, color: AppColors.greenDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(account.bankName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                if (account.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(account.accountNumber, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
              Text(account.accountName, style: const TextStyle(fontSize: 12.5, color: AppColors.subText)),
            ]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.subText, size: 20),
            onSelected: (v) {
              if (v == 'default') onSetDefault();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              if (!account.isDefault)
                const PopupMenuItem(value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: AppColors.redDark))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddBankForm extends StatelessWidget {
  final TextEditingController bankCtrl, acctCtrl, nameCtrl;
  final VoidCallback onSave, onCancel;

  const _AddBankForm({required this.bankCtrl, required this.acctCtrl, required this.nameCtrl, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('New payout account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        const SizedBox(height: 16),
        VTextField(label: 'Bank name', controller: bankCtrl, hint: 'e.g. GTBank, Access Bank'),
        const SizedBox(height: 12),
        VTextField(label: 'Account number', controller: acctCtrl, hint: '0123456789', keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        VTextField(label: 'Account name', controller: nameCtrl, hint: 'As on your bank statement'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: onCancel,
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('Cancel', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.subText2))),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: VButton(label: 'Save', onTap: onSave)),
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const SizedBox(height: 40),
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(20)),
      child: const Icon(Icons.account_balance_outlined, color: AppColors.subText, size: 30),
    ),
    const SizedBox(height: 16),
    const Text('No payout accounts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText)),
    const SizedBox(height: 6),
    const Text('Add a bank account to receive withdrawals.', style: TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    const SizedBox(height: 20),
    VButton(label: '+ Add account', onTap: onAdd),
  ]);
}
