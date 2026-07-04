import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';

class SubmitWorkScreen extends ConsumerStatefulWidget {
  final String contractId;
  final MilestoneModel milestone;

  const SubmitWorkScreen({super.key, required this.contractId, required this.milestone});

  @override
  ConsumerState<SubmitWorkScreen> createState() => _SubmitWorkScreenState();
}

class _SubmitWorkScreenState extends ConsumerState<SubmitWorkScreen> {
  final _noteCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _submitting = false;

  bool get _valid => _noteCtrl.text.trim().isNotEmpty;

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
                  const Text('Submit work', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: const Color(0xFFFFF3CC), borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.task_outlined, color: AppColors.gold, size: 18),
                          ),
                          const SizedBox(width: 11),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Milestone', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                            Text(widget.milestone.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          ])),
                          Text(formatUSD(widget.milestone.amount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('What did you deliver?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: 'Describe the work you completed so the client can review and release funds…'),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2),
                        children: [
                          TextSpan(text: 'Link to work '),
                          TextSpan(text: '(optional)', style: TextStyle(fontWeight: FontWeight.w400, color: AppColors.subText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _linkCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Figma, Drive, GitHub…',
                        prefixIcon: Icon(Icons.link, color: AppColors.subText, size: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_outlined, color: AppColors.greenDark, size: 20),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Your funds stay locked in escrow. The client reviews this submission and releases ${formatUSD(widget.milestone.amount)} once approved.',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF5C5320), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    VButton(
                      label: _submitting ? 'Submitting…' : 'Submit for review',
                      onTap: _valid && !_submitting ? _submit : null,
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

  void _submit() async {
    setState(() => _submitting = true);
    final note = _noteCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    // Optimistic local update.
    final updated = widget.milestone.copyWith(
      status: MilestoneStatus.submitted,
      deliveryNote: note,
      deliveryLink: link.isEmpty ? null : link,
    );
    ref.read(contractsProvider.notifier).updateMilestone(widget.contractId, widget.milestone.id, updated);
    try {
      await ref.read(escrowServiceProvider).markMilestoneDelivered(widget.milestone.id, note: note, link: link);
      if (!mounted) return;
      Navigator.of(context).pop();
      showVToast(context, 'Work submitted for review');
    } on ApiException catch (e) {
      if (mounted) showVToast(context, e.message);
    } finally {
      await refreshContracts(ref);
      if (mounted) setState(() => _submitting = false);
    }
  }
}
