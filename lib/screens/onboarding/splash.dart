import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../main/shell.dart';
import 'intro.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _advance);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _advance() async {
    // Try to silently resume a previous session via the stored refresh
    // token before falling back to the normal onboarding flow.
    final resumed = await _tryResumeSession();
    if (!mounted) return;

    if (resumed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IntroScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<bool> _tryResumeSession() async {
    try {
      final refreshed = await ref.read(authServiceProvider).silentRefresh();
      if (!refreshed) return false;

      final user = await ref.read(authServiceProvider).me();
      ref.read(userProvider.notifier).applyAuthResult(user);
      await refreshWalletBalance(ref);
      try {
        await refreshContracts(ref);
      } catch (_) {
        // Non-fatal — the contracts list just stays empty until the next refresh.
      }
      ref.read(isLoggedInProvider.notifier).state = true;
      ref.read(onboardingCompleteProvider.notifier).state = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellow,
      body: GestureDetector(
        onTap: _advance,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: _VeritasSymbol(),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnim,
                child: const VeritasLogo(size: 32, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VeritasSymbol extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 74,
      child: Stack(
        children: [
          Positioned(left: 0, child: _circle()),
          Positioned(left: 38, child: _circle()),
          Positioned(left: 76, child: _circle()),
        ],
      ),
    );
  }

  Widget _circle() => Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkText, width: 5),
        ),
      );
}
