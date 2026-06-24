import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../main/shell.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String dob;
  final String email;
  final String phone;
  final String country;

  const CreatePasswordScreen({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dob,
    required this.email,
    required this.phone,
    required this.country,
  });

  @override
  ConsumerState<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPwd = false;
  bool _showConfirm = false;

  bool get _pwdOk => _pwdCtrl.text.length >= 8;
  bool get _match => _pwdCtrl.text == _confirmCtrl.text && _pwdCtrl.text.isNotEmpty;
  bool get _valid => _pwdOk && _match;

  List<({String label, bool met})> get _rules => [
    (label: 'At least 8 characters', met: _pwdCtrl.text.length >= 8),
    (label: 'Contains a number', met: _pwdCtrl.text.contains(RegExp(r'\d'))),
    (label: 'Contains a letter', met: _pwdCtrl.text.contains(RegExp(r'[a-zA-Z]'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const VBackButton(),
                  const SizedBox(width: 14),
                  const Text('Create password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    child: Container(height: 7, decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(6))),
                  ),
                )),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create your password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    const Text('You\'ll use this to log in to Veritas.', style: TextStyle(fontSize: 14, color: AppColors.subText2)),
                    const SizedBox(height: 28),
                    _PasswordField(label: 'Password', ctrl: _pwdCtrl, show: _showPwd, onToggle: () => setState(() => _showPwd = !_showPwd), onChanged: () => setState(() {})),
                    const SizedBox(height: 12),
                    ..._rules.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(r.met ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: r.met ? AppColors.greenDark : AppColors.subText),
                          const SizedBox(width: 8),
                          Text(r.label, style: TextStyle(fontSize: 13, color: r.met ? AppColors.greenDark : AppColors.subText)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 18),
                    _PasswordField(label: 'Confirm password', ctrl: _confirmCtrl, show: _showConfirm, onToggle: () => setState(() => _showConfirm = !_showConfirm), onChanged: () => setState(() {})),
                    if (_confirmCtrl.text.isNotEmpty && !_match)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text("Passwords don't match", style: TextStyle(fontSize: 13, color: AppColors.red)),
                      ),
                    const SizedBox(height: 32),
                    VButton(
                      label: 'Create account',
                      onTap: _valid
                          ? () {
                              ref.read(userProvider.notifier).initFromOnboarding(
                                firstName: widget.firstName,
                                middleName: widget.middleName,
                                lastName: widget.lastName,
                                email: widget.email,
                                phone: widget.phone,
                                country: widget.country,
                                password: _pwdCtrl.text,
                              );

                              // Activate any escrow contracts sent to this email
                              // before the user had a Veritas account.
                              final claimed = ref.read(contractsProvider.notifier)
                                  .claimContractsByEmail(widget.email);
                              if (claimed > 0) {
                                ref.read(notificationsProvider.notifier).addPendingContractNotif(
                                  claimed,
                                  widget.firstName,
                                );
                              }

                              ref.read(isLoggedInProvider.notifier).state = true;
                              ref.read(onboardingCompleteProvider.notifier).state = true;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const MainShell()),
                                (_) => false,
                              );
                            }
                          : null,
                    ),
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
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool show;
  final VoidCallback onToggle;
  final VoidCallback onChanged;

  const _PasswordField({required this.label, required this.ctrl, required this.show, required this.onToggle, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
        const SizedBox(height: 9),
        TextField(
          controller: ctrl,
          obscureText: !show,
          onChanged: (_) => onChanged(),
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
}
