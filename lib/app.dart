import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'screens/onboarding/splash.dart';
import 'screens/onboarding/intro.dart';
import 'screens/onboarding/auth_choice.dart';
import 'screens/onboarding/country_picker.dart';
import 'screens/onboarding/phone_input.dart';
import 'screens/onboarding/personal_details.dart';
import 'screens/onboarding/create_password.dart';
import 'screens/auth/login.dart';
import 'screens/auth/otp.dart';
import 'screens/main/shell.dart';

class VeritasApp extends ConsumerWidget {
  const VeritasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return MaterialApp(
      title: 'Veritas',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: isLoggedIn ? const MainShell() : const SplashScreen(),
      routes: {
        '/intro': (_) => const IntroScreen(),
        '/auth-choice': (_) => const AuthChoiceScreen(),
        '/country-picker': (_) => const CountryPickerScreen(),
        '/phone-input': (_) => const PhoneInputScreen(),
        '/personal-details': (_) => const PersonalDetailsScreen(),
        '/create-password': (_) => const CreatePasswordScreen(),
        '/login': (_) => const LoginScreen(),
        '/otp': (_) => const OtpScreen(),
        '/main': (_) => const MainShell(),
      },
    );
  }
}
