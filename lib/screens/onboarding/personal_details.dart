import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'create_password.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String country;
  final String phone;

  const PersonalDetailsScreen({super.key, required this.country, required this.phone});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _firstCtrl = TextEditingController();
  final _middleCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool get _valid {
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailCtrl.text);
    return _firstCtrl.text.isNotEmpty &&
        _lastCtrl.text.isNotEmpty &&
        _dobCtrl.text.length >= 10 &&
        emailOk;
  }

  String _formatDob(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    if (digits.length <= 4) return '${digits.substring(0, 2)} / ${digits.substring(2)}';
    return '${digits.substring(0, 2)} / ${digits.substring(2, 4)} / ${digits.substring(4, digits.length.clamp(0, 8))}';
  }

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
                  const Text('About you', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressBar(step: 3),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us about you',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your legal name and details — as they appear on your government ID.',
                      style: TextStyle(fontSize: 14, color: AppColors.subText2, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    VTextField(label: 'First name', controller: _firstCtrl, hint: 'e.g. Amaka', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 18),
                    VTextField(label: 'Middle name (optional)', controller: _middleCtrl, hint: 'e.g. Grace'),
                    const SizedBox(height: 18),
                    VTextField(label: 'Last name', controller: _lastCtrl, hint: 'e.g. Okafor', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of birth', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                        const SizedBox(height: 9),
                        TextField(
                          controller: _dobCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final formatted = _formatDob(v);
                            if (formatted != _dobCtrl.text) {
                              _dobCtrl.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                            setState(() {});
                          },
                          decoration: const InputDecoration(hintText: 'DD / MM / YYYY'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    VTextField(
                      label: 'Email address',
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 32),
                    VButton(
                      label: 'Continue',
                      onTap: _valid
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreatePasswordScreen(
                                    firstName: _firstCtrl.text,
                                    middleName: _middleCtrl.text,
                                    lastName: _lastCtrl.text,
                                    dob: _dobCtrl.text,
                                    email: _emailCtrl.text,
                                    phone: widget.phone,
                                    country: widget.country,
                                  ),
                                ),
                              )
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

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
          child: Container(height: 7, decoration: BoxDecoration(color: i < step ? AppColors.yellow : AppColors.lightBg, borderRadius: BorderRadius.circular(6))),
        ),
      )),
    );
  }
}
