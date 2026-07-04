import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';

class RequestChangesScreen extends ConsumerStatefulWidget {
  final String contractId;
  final MilestoneModel milestone;

  const RequestChangesScreen({super.key, required this.contractId, required this.milestone});

  @override
  ConsumerState<RequestChangesScreen> createState() => _RequestChangesScreenState();
}

class _RequestChangesScreenState extends ConsumerState<RequestChangesScreen> {
  final _noteCtrl = TextEditingController();
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
                  const Text('Request changes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                            decoration: BoxDecoration(color: const Color(0xFFFCE7DD), borderRadius: BorderRadius.circular(11)),
                            child: const Icon(Icons.replay, color: AppColors.orange, size: 18),
                          ),
                          const SizedBox(width: 11),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Milestone', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                            Text(widget.milestone.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                          ])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('What needs to change?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 9),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: 'Tell the freelancer what to revise before you release funds…'),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.orange, size: 20),
                          SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Funds stay locked in escrow. The freelancer is notified and can revise and resubmit the work.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF5C5320), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    VButton(
                      label: _submitting ? 'Sending…' : 'Send back for changes',
                      onTap: _valid && !_submitting ? _submit : null,
                      bg: const Color(0xFFFCE7DD),
                      fg: AppColors.orange,
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
    try {
      await ref.read(escrowServiceProvider).rejectMilestone(widget.milestone.id, note);
      await refreshContracts(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
      showVToast(context, 'Sent back to the freelancer for changes');
    } on ApiException catch (e) {
      if (mounted) showVToast(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
