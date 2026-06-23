import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import 'otp.dart';
import '../onboarding/country_picker.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _showPwd = false;

  bool get _valid => _emailCtrl.text.contains('@') && _pwdCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const VBackButton(),
              const SizedBox(height: 32),
              const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Log in to your Veritas account.', style: TextStyle(fontSize: 14.5, color: AppColors.subText2)),
              const SizedBox(height: 32),
              VTextField(
                label: 'Email address',
                controller: _emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subText2)),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _pwdCtrl,
                    obscureText: !_showPwd,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _showPwd = !_showPwd),
                        child: Icon(_showPwd ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.subText, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              VButton(
                label: 'Log In',
                onTap: _valid
                    ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()))
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Face ID / biometric shortcut — bypass to OTP
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.face_unlock_outlined, color: AppColors.darkText, size: 22),
                        SizedBox(width: 8),
                        Text('Use Face ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CountryPickerScreen())),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(fontSize: 14, color: AppColors.subText2),
                      children: [
                        TextSpan(text: 'Sign up', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkText)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
