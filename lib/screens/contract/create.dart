import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class CreateEscrowScreen extends ConsumerStatefulWidget {
  const CreateEscrowScreen({super.key});

  @override
  ConsumerState<CreateEscrowScreen> createState() => _CreateEscrowScreenState();
}

class _CreateEscrowScreenState extends ConsumerState<CreateEscrowScreen> {
  final _projectCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();
  int _milestoneCount = 2;
  bool _recipientResolved = false;
  String _resolvedName = '';

  final _knownTags = {
    '@danielokafor': 'Daniel Okafor',
    '@zaramensah': 'Zara Mensah',
    '@techtalk': 'TechTalk Media',
    '@amaka': 'Amaka Okafor',
  };

  double get _amount => double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  double get _perMilestone => _milestoneCount > 0 ? _amount / _milestoneCount : 0;

  bool get _valid =>
      _projectCtrl.text.isNotEmpty &&
      _amount > 0 &&
      _recipientResolved;

  void _resolveRecipient(String v) {
    final tag = v.trim().toLowerCase();
    final name = _knownTags[tag];
    setState(() {
      if (name != null) {
        _recipientResolved = true;
        _resolvedName = name;
      } else if (v.contains('@') && v.contains('.')) {
        _recipientResolved = true;
        _resolvedName = v;
      } else {
        _recipientResolved = false;
        _resolvedName = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('New escrow', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VTextField(label: 'Project name', controller: _projectCtrl, hint: 'e.g. Brand identity redesign', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 18),
                    // Recipient
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Freelancer (VeritasTag or email)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                        const SizedBox(height: 9),
                        TextField(
                          controller: _recipientCtrl,
                          onChanged: _resolveRecipient,
                          decoration: InputDecoration(
                            hintText: '@handle or email@example.com',
                            suffixIcon: _recipientResolved
                                ? const Icon(Icons.check_circle, color: AppColors.greenDark, size: 20)
                                : null,
                          ),
                        ),
                        if (_recipientResolved) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(10)),
                            child: Row(children: [
                              const Icon(Icons.person_outline, color: AppColors.greenDark, size: 16),
                              const SizedBox(width: 7),
                              Text(_resolvedName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.greenDark)),
                              const SizedBox(width: 5),
                              const Text('· On Veritas', style: TextStyle(fontSize: 12, color: AppColors.greenDark)),
                            ]),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contract amount (USD)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                        const SizedBox(height: 9),
                        TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(prefixText: '\$ ', hintText: '1,000.00'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text('Number of milestones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepBtn(icon: Icons.remove, onTap: _milestoneCount > 1 ? () => setState(() => _milestoneCount--) : null),
                        const SizedBox(width: 20),
                        Column(children: [
                          Text('$_milestoneCount', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -1)),
                          if (_amount > 0 && _milestoneCount > 0)
                            Text('≈ ${formatUSD(_perMilestone)} each', style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                        ]),
                        const SizedBox(width: 20),
                        _StepBtn(icon: Icons.add, onTap: _milestoneCount < 10 ? () => setState(() => _milestoneCount++) : null),
                      ],
                    ),
                    if (_amount > 0 && _recipientResolved && _projectCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          _SumRow('Contract value', formatUSD(_amount)),
                          _SumRow('Veritas fee (1.5%)', formatUSD(_amount * 0.015)),
                          const Divider(height: 20, color: AppColors.border),
                          _SumRow('You pay', formatUSD(_amount * 1.015), bold: true),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    VButton(
                      label: 'Fund escrow',
                      onTap: _valid ? _create : null,
                    ),
                    const SizedBox(height: 12),
                    if (_recipientResolved && _amount > 0)
                      Center(
                        child: Text(
                          'Funds will be locked until ${_resolvedName.split(' ').first} completes milestones',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.subText, height: 1.5),
                        ),
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

  void _create() async {
    final ok = await showVConfirm(
      context,
      title: 'Fund ${formatUSD(_amount)}?',
      body: 'Funds will be locked in escrow until milestones are completed and released.',
      confirmLabel: 'Fund escrow',
    );
    if (ok != true) return;

    final milestones = List.generate(_milestoneCount, (i) => MilestoneModel(
      id: 'nm${i + 1}',
      title: 'Milestone ${i + 1}',
      amount: _perMilestone,
    ));

    final contract = EscrowContract(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      project: _projectCtrl.text,
      clientName: ref.read(userProvider).fullName,
      freelancerName: _resolvedName,
      clientTag: ref.read(userProvider).veritasTag != null ? '@${ref.read(userProvider).veritasTag}' : '',
      freelancerTag: _recipientCtrl.text,
      totalAmount: _amount,
      milestones: milestones,
      avatarBg: '#E3ECFF',
      avatarFg: '#2D6BDB',
      initials: _resolvedName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
    );

    ref.read(contractsProvider.notifier).addContract(contract);
    ref.read(userProvider.notifier).debitClient(_amount);

    if (mounted) {
      Navigator.of(context).pop();
      showVToast(context, 'Escrow funded — ${_resolvedName.split(' ').first} has been notified!');
    }
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.dark : AppColors.lightBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: onTap != null ? Colors.white : AppColors.subText, size: 22),
      ),
    );
  }
}

Widget _SumRow(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.5, color: bold ? AppColors.darkText : AppColors.subText2, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13.5, color: AppColors.darkText, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
      ],
    ),
  );
}
