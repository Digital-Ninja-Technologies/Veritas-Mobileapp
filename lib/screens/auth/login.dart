import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../services/api_client.dart';
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
  bool _loading = false;

  bool get _valid => _emailCtrl.text.contains('@') && _pwdCtrl.text.isNotEmpty;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final user = await ref.read(authServiceProvider).login(
            email: _emailCtrl.text.trim().toLowerCase(),
            password: _pwdCtrl.text,
          );
      ref.read(userProvider.notifier).applyAuthResult(user);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
    } on ApiException catch (e) {
      if (mounted) showVToast(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // "Use Face ID" is a quick sign-back-in using a previously stored refresh
  // token — it does not bypass real authentication.
  Future<void> _quickSignIn() async {
    setState(() => _loading = true);
    try {
      final resumed = await ref.read(authServiceProvider).silentRefresh();
      if (!resumed) {
        if (mounted) showVToast(context, 'No saved session — please log in with your email and password.');
        return;
      }
      final user = await ref.read(authServiceProvider).me();
      ref.read(userProvider.notifier).applyAuthResult(user);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
    } catch (_) {
      if (mounted) showVToast(context, 'Couldn\'t sign you back in — please log in with your email and password.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                label: _loading ? 'Logging in...' : 'Log In',
                onTap: _valid && !_loading ? _login : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _loading ? null : _quickSignIn,
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
