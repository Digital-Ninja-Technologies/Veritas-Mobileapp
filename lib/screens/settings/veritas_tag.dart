import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class VeritasTagScreen extends ConsumerStatefulWidget {
  const VeritasTagScreen({super.key});

  @override
  ConsumerState<VeritasTagScreen> createState() => _VeritasTagScreenState();
}

class _VeritasTagScreenState extends ConsumerState<VeritasTagScreen> {
  late TextEditingController _ctrl;
  bool _checking = false;
  bool? _available;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(userProvider).veritasTag ?? '';
    _ctrl = TextEditingController(text: existing);
  }

  void _check(String value) async {
    if (value.isEmpty) {
      setState(() { _available = null; _checking = false; });
      return;
    }
    setState(() { _checking = true; _available = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final taken = ['amaka', 'danielokafor', 'zaramensah', 'techtalk'];
    setState(() {
      _checking = false;
      _available = !taken.contains(value.toLowerCase());
    });
  }

  bool get _valid => _available == true && _ctrl.text.length >= 3;

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(userProvider).veritasTag;

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
                  const Text('VeritasTag', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.alternate_email, color: AppColors.darkText, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Your VeritasTag', style: TextStyle(fontSize: 12, color: Color(0xFF9C9A7C))),
                            const SizedBox(height: 2),
                            Text(
                              current != null ? '@$current' : 'Not set',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Choose a tag', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ctrl,
                      onChanged: _check,
                      decoration: InputDecoration(
                        prefixText: '@',
                        hintText: 'yourname',
                        suffixIcon: _checking
                            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.subText)))
                            : _available == true
                                ? const Icon(Icons.check_circle, color: AppColors.greenDark, size: 20)
                                : _available == false
                                    ? const Icon(Icons.cancel, color: AppColors.redDark, size: 20)
                                    : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_available == true)
                      const Row(children: [Icon(Icons.check, color: AppColors.greenDark, size: 14), SizedBox(width: 6), Text('This tag is available', style: TextStyle(fontSize: 12.5, color: AppColors.greenDark))])
                    else if (_available == false)
                      const Row(children: [Icon(Icons.close, color: AppColors.redDark, size: 14), SizedBox(width: 6), Text('This tag is already taken', style: TextStyle(fontSize: 12.5, color: AppColors.redDark))])
                    else
                      const Text('3–20 characters, letters and numbers only', style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('About VeritasTags', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                        SizedBox(height: 8),
                        Text('Your VeritasTag is how clients find and pay you on Veritas. Share it instead of your email or account number.', style: TextStyle(fontSize: 13, color: AppColors.subText2, height: 1.5)),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    VButton(
                      label: 'Save tag',
                      onTap: _valid ? _save : null,
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

  void _save() {
    ref.read(userProvider.notifier).updateTag(_ctrl.text.trim().toLowerCase());
    Navigator.of(context).pop();
    showVToast(context, 'VeritasTag saved!');
  }
}
