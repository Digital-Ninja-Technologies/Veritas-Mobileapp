import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class DisputeScreen extends ConsumerStatefulWidget {
  final EscrowContract contract;

  const DisputeScreen({super.key, required this.contract});

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> {
  String? _selectedMilestoneId;
  String? _selectedReason;
  final _detailCtrl = TextEditingController();
  final List<String> _evidence = [];
  bool _submitted = false;
  String _caseRef = '';

  final _reasons = [
    'Work not delivered',
    'Not as described',
    'Late delivery',
    'Quality issues',
    'Something else',
  ];

  bool get _valid =>
      _selectedMilestoneId != null &&
      _selectedReason != null &&
      _detailCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessView(caseRef: _caseRef);

    final milestones = widget.contract.milestones
        .where((m) => m.status != MilestoneStatus.released)
        .toList();

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
                  const Text('Raise a dispute', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: const Color(0xFFFCE2E0), borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.redDark, size: 18),
                          SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Funds stay locked in escrow while we review. Our resolution team looks at both sides\' evidence and decides the outcome.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF7A2820), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Which milestone?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 10),
                    ...milestones.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMilestoneId = m.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _selectedMilestoneId == m.id ? AppColors.dark : AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(m.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                                const SizedBox(height: 1),
                                Text(formatUSD(m.amount), style: const TextStyle(fontSize: 12, color: AppColors.subText)),
                              ])),
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _selectedMilestoneId == m.id ? AppColors.dark : AppColors.border, width: 2)),
                                child: _selectedMilestoneId == m.id
                                    ? Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle))
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 12),
                    const Text('What\'s the problem?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reasons.map((r) {
                        final active = _selectedReason == r;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedReason = r),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: active ? AppColors.dark : Colors.white,
                              border: Border.all(color: active ? AppColors.dark : AppColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(r, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.darkText)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    const Text('Describe what happened', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _detailCtrl,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: 'Explain the issue with as much detail as you can…'),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Evidence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                        GestureDetector(
                          onTap: () => setState(() => _evidence.add('Screenshot_${_evidence.length + 1}.png')),
                          child: const Text('+ Add file', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.blue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._evidence.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.attach_file, color: AppColors.gold, size: 17),
                          const SizedBox(width: 11),
                          Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.darkText))),
                          GestureDetector(
                            onTap: () => setState(() => _evidence.removeAt(e.key)),
                            child: const Icon(Icons.close, color: AppColors.redDark, size: 16),
                          ),
                        ]),
                      ),
                    )),
                    const SizedBox(height: 24),
                    VButton(label: 'Submit dispute', onTap: _valid ? _submit : null, bg: AppColors.redDark, fg: Colors.white),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final ref2 = 'DSP-${4000 + DateTime.now().millisecondsSinceEpoch % 1000}';
    final mid = _selectedMilestoneId!;
    final m = widget.contract.milestones.firstWhere((m) => m.id == mid);
    ref.read(contractsProvider.notifier).updateMilestone(widget.contract.id, mid, m.copyWith(
      status: MilestoneStatus.inDispute,
      disputeRef: ref2,
      disputeStatus: DisputeStatus.open,
    ));
    setState(() { _submitted = true; _caseRef = ref2; });
  }
}

class _SuccessView extends StatelessWidget {
  final String caseRef;
  const _SuccessView({required this.caseRef});

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
                      decoration: BoxDecoration(color: const Color(0xFFFCE2E0), borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.gavel_outlined, color: AppColors.redDark, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('Dispute submitted', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'Case $caseRef has been opened. Our resolution team will review within 48 hours. Funds stay locked in escrow until resolved.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        _InfoRow('Case reference', caseRef),
                        _InfoRow('Status', 'Under review'),
                        _InfoRow('Estimated resolution', '48 hours'),
                      ]),
                    ),
                  ],
                ),
              ),
              VButton(
                label: 'Back to contract',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _InfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2)),
        Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      ],
    ),
  );
}
