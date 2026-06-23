import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'auth_choice.dart';

const _slides = [
  (
    title: 'We give freelancers & clients\npeace of mind',
    body: 'Your money is held safely in escrow. The client can\'t pay late, and the freelancer can\'t disappear with funds.',
    image: 'assets/images/vault-lock.png',
  ),
  (
    title: 'Receive payments locally\nwith ease',
    body: 'Get paid in USD, withdraw in NGN, KES, GHS or any local currency — at fair FX rates, with no hidden charges.',
    image: 'assets/images/vault-2.png',
  ),
  (
    title: 'Swift escrow and\nglobal payment',
    body: 'Create a contract, fund it in minutes, and release milestones as work is delivered. Both parties protected.',
    image: 'assets/images/vault-3.png',
  ),
];

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  int _index = 0;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _goAuth();
    }
  }

  void _goAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: List.generate(_slides.length, (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < _slides.length - 1 ? 6 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 7,
                      decoration: BoxDecoration(
                        color: i <= _index ? AppColors.yellow : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _goAuth,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Skip',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.subText),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: AppColors.yellow.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _index < _slides.length - 1 ? 'Continue' : 'Get Started',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText),
                            ),
                            const SizedBox(width: 9),
                            const Icon(Icons.arrow_forward, color: AppColors.darkText, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final ({String title, String body, String image}) slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            slide.title,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              fontSize: 32,
              height: 1.06,
              color: AppColors.darkText,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontSize: 14.5,
              height: 1.5,
              color: Color(0xFF5C5320),
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.yellow.withOpacity(0.45), AppColors.yellow.withOpacity(0)],
                      ),
                    ),
                  ),
                  Image.asset(
                    slide.image,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.lightBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.lock_outline, size: 80, color: AppColors.subText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
