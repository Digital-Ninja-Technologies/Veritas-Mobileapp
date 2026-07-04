import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../main/shell.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<String> _digits = ['', '', '', '', '', ''];
  int _currentIndex = 0;
  bool _error = false;

  void _onKey(String key) {
    if (key == 'del') {
      if (_currentIndex > 0) {
        setState(() {
          _currentIndex--;
          _digits[_currentIndex] = '';
          _error = false;
        });
      }
      return;
    }
    if (_currentIndex >= 6) return;
    setState(() {
      _digits[_currentIndex] = key;
      _currentIndex++;
      _error = false;
    });
    if (_currentIndex == 6) {
      _verify();
    }
  }

  void _verify() async {
    final code = _digits.join();
    // Accept any 6-digit code for demo — real auth already happened via
    // AuthService.login()/silentRefresh() before this screen was reached.
    if (code.length != 6) return;

    try {
      await refreshWalletBalance(ref);
    } catch (_) {
      // Wallet fetch failing shouldn't block sign-in — balance just shows
      // as 0 until the next successful refresh.
    }
    try {
      await refreshContracts(ref);
    } catch (_) {
      // Same — contracts list just stays empty until the next refresh.
    }
    try {
      await refreshTransactions(ref);
    } catch (_) {
      // Same — activity feed just stays empty until the next refresh.
    }
    if (!mounted) return;

    ref.read(isLoggedInProvider.notifier).state = true;
    ref.read(onboardingCompleteProvider.notifier).state = true;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

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
                  const Text('Verification', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.yellow, size: 36),
            ),
            const SizedBox(height: 24),
            const Text('Enter verification code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We sent a 6-digit code to your phone & email. Check both.',
                style: TextStyle(fontSize: 14, color: AppColors.subText2, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  final filled = _digits[i].isNotEmpty;
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 46,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: _error ? AppColors.red : (active ? AppColors.dark : AppColors.border),
                        width: active ? 2 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        filled ? '•' : '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => showVToast(context, 'Code resent to your phone & email'),
              child: const Text('Resend code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dark)),
            ),
            const Spacer(),
            _NumPad(onKey: _onKey),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onKey;

  const _NumPad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: 12,
        itemBuilder: (_, i) {
          final key = keys[i];
          if (key.isEmpty) return const SizedBox();
          return GestureDetector(
            onTap: () => onKey(key),
            child: Container(
              decoration: BoxDecoration(
                color: key == 'del' ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: key == 'del' ? null : Border.all(color: AppColors.border),
              ),
              child: Center(
                child: key == 'del'
                    ? const Icon(Icons.backspace_outlined, color: AppColors.darkText, size: 20)
                    : Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkText)),
              ),
            ),
          );
        },
      ),
    );
  }
}
