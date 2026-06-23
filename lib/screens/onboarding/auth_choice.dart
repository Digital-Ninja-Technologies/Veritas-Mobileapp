import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../auth/login.dart';
import 'country_picker.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const VeritasLogo(size: 28),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/vault-trust.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.lightBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(child: Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppColors.subText)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Earn in USD.\nWithdraw in your currency.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkText,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Escrow protection for freelancers and clients worldwide.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: AppColors.subText2,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              VButton(
                label: 'Create an account',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CountryPickerScreen()),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Log In',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.darkText),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
