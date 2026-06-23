import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  bool _done = false;

  bool get _hasMin => _newCtrl.text.length >= 8;
  bool get _hasUpper => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _matches => _newCtrl.text == _confirmCtrl.text && _newCtrl.text.isNotEmpty;
  bool get _valid => _currentCtrl.text.isNotEmpty && _hasMin && _hasUpper && _hasNumber && _matches;

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: const Color(0xFFE8F5EF), borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.lock_reset, color: AppColors.greenDark, size: 40),
                ),
                const SizedBox(height: 24),
                const Text('Password changed', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                const SizedBox(height: 12),
                const Text('Your password has been updated. Use it next time you log in.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5, color: AppColors.subText2, height: 1.6)),
                const SizedBox(height: 40),
                VButton(label: 'Done', onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ),
      );
    }

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
                  const Text('Change password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
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
                    _PassField(label: 'Current password', ctrl: _currentCtrl, show: _showCurrent, onToggle: () => setState(() => _showCurrent = !_showCurrent), onChanged: (_) => setState(() {})),
                    const SizedBox(height: 16),
                    _PassField(label: 'New password', ctrl: _newCtrl, show: _showNew, onToggle: () => setState(() => _showNew = !_showNew), onChanged: (_) => setState(() {})),
                    const SizedBox(height: 16),
                    _PassField(label: 'Confirm new password', ctrl: _confirmCtrl, show: _showConfirm, onToggle: () => setState(() => _showConfirm = !_showConfirm), onChanged: (_) => setState(() {})),
                    if (_newCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                        child: Column(children: [
                          _Rule('At least 8 characters', _hasMin),
                          _Rule('At least one uppercase letter', _hasUpper),
                          _Rule('At least one number', _hasNumber),
                          _Rule('Passwords match', _matches),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 28),
                    VButton(label: 'Change password', onTap: _valid ? () => setState(() => _done = true) : null),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool show;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  const _PassField({required this.label, required this.ctrl, required this.show, required this.onToggle, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
      const SizedBox(height: 9),
      TextField(
        controller: ctrl,
        obscureText: !show,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '••••••••',
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.subText, size: 20),
          ),
        ),
      ),
    ],
  );
}

Widget _Rule(String text, bool met) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(children: [
    Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, color: met ? AppColors.greenDark : AppColors.border, size: 16),
    const SizedBox(width: 10),
    Text(text, style: TextStyle(fontSize: 13, color: met ? AppColors.greenDark : AppColors.subText2)),
  ]),
);
