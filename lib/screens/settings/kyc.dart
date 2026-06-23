import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  int _step = 0;
  String? _docType;

  final _docs = ['National ID', 'International Passport', 'Driver\'s Licence'];

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
                  GestureDetector(
                    onTap: () => _step > 0 ? setState(() => _step--) : Navigator.of(context).pop(),
                    child: const VBackButton(),
                  ),
                  const SizedBox(width: 14),
                  const Text('Identity verification', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressBar(step: _step, total: 4),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _DocTypeStep(docType: _docType, onSelect: (d) => setState(() => _docType = d), onNext: () => setState(() => _step = 1));
      case 1: return _ScanStep(title: 'Scan front of document', icon: Icons.credit_card_outlined, sub: 'Place the front of your ${_docType ?? 'document'} in the frame', onNext: () => setState(() => _step = 2));
      case 2: return _ScanStep(title: 'Scan back of document', icon: Icons.flip, sub: 'Flip your document and scan the back', onNext: () => setState(() => _step = 3));
      case 3: return _ScanStep(title: 'Take a selfie', icon: Icons.face_outlined, sub: 'Look straight at the camera and make sure your face is clearly visible', onNext: () => setState(() => _step = 4), selfie: true);
      case 4: return _SubmittedView(onDone: () => Navigator.of(context).pop());
      default: return const SizedBox.shrink();
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final int step, total;
  const _ProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: i <= step ? AppColors.dark : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      )),
    );
  }
}

class _DocTypeStep extends StatelessWidget {
  final String? docType;
  final void Function(String) onSelect;
  final VoidCallback onNext;
  final _docs = const ['National ID', 'International Passport', 'Driver\'s Licence'];

  const _DocTypeStep({required this.docType, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Which document will you use?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
      const SizedBox(height: 6),
      const Text('Make sure the document is valid, not expired, and issued by a government.', style: TextStyle(fontSize: 13.5, color: AppColors.subText2, height: 1.5)),
      const SizedBox(height: 24),
      ..._docs.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => onSelect(d),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: docType == d ? AppColors.dark : AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.credit_card_outlined, color: AppColors.darkText, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(d, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText))),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: docType == d ? AppColors.dark : AppColors.border, width: 2)),
                child: docType == d ? Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle)) : null,
              ),
            ]),
          ),
        ),
      )),
      const SizedBox(height: 12),
      VButton(label: 'Continue', onTap: docType != null ? onNext : null),
      const SizedBox(height: 24),
    ]);
  }
}

class _ScanStep extends StatefulWidget {
  final String title, sub;
  final IconData icon;
  final bool selfie;
  final VoidCallback onNext;
  const _ScanStep({required this.title, required this.sub, required this.icon, required this.onNext, this.selfie = false});

  @override
  State<_ScanStep> createState() => _ScanStepState();
}

class _ScanStepState extends State<_ScanStep> {
  bool _captured = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
      const SizedBox(height: 6),
      Text(widget.sub, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2, height: 1.5)),
      const SizedBox(height: 28),
      GestureDetector(
        onTap: () => setState(() => _captured = true),
        child: Container(
          height: widget.selfie ? 260 : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _captured ? const Color(0xFFE8F5EF) : AppColors.lightBg,
            border: Border.all(color: _captured ? AppColors.greenDark : AppColors.border, width: 2, style: _captured ? BorderStyle.solid : BorderStyle.solid),
            borderRadius: BorderRadius.circular(widget.selfie ? 120 : 16),
          ),
          child: _captured
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.greenDark, size: 48),
                  const SizedBox(height: 10),
                  const Text('Captured!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.greenDark)),
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(widget.icon, color: AppColors.subText, size: 40),
                  const SizedBox(height: 12),
                  const Text('Tap to capture', style: TextStyle(fontSize: 14, color: AppColors.subText)),
                ]),
        ),
      ),
      const SizedBox(height: 28),
      VButton(label: _captured ? 'Looks good, continue' : 'Capture', onTap: _captured ? widget.onNext : () => setState(() => _captured = true)),
      const SizedBox(height: 8),
      if (_captured)
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _captured = false),
            child: const Text('Retake', style: TextStyle(fontSize: 14, color: AppColors.subText2, fontWeight: FontWeight.w600)),
          ),
        ),
      const SizedBox(height: 24),
    ]);
  }
}

class _SubmittedView extends StatelessWidget {
  final VoidCallback onDone;
  const _SubmittedView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 40),
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.verified_outlined, color: AppColors.greenDark, size: 40),
      ),
      const SizedBox(height: 24),
      const Text('Submitted for review', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
      const SizedBox(height: 12),
      const Text(
        'Your documents are under review. This usually takes 1–2 business hours. You\'ll be notified once verified.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6),
      ),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _InfoRow('Status', 'Under review'),
          _InfoRow('Est. time', '1–2 business hours'),
          _InfoRow('Contact', 'info@useveritasapp.com'),
        ]),
      ),
      const SizedBox(height: 28),
      VButton(label: 'Back to profile', onTap: onDone),
      const SizedBox(height: 24),
    ]);
  }
}

Widget _InfoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2)),
    Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
  ]),
);
