import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';
import '../auth/login.dart';
import 'change_password.dart';
import 'edit_profile.dart';
import 'legal.dart';
import 'payout_methods.dart';
import 'pin_flow.dart';
import 'preference_picker.dart';
import 'veritas_tag.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifPayments = true;
  bool _notifMilestones = true;
  bool _notifDisputes = true;
  bool _notifMarketing = false;
  bool _biometrics = true;

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Widget _iconBox(IconData icon, Color bg, Color fg) => Container(
        width: 36,
        height: 36,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: fg, size: 18),
      );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
                  const Text('Settings',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VSectionLabel('Account'),
                    const SizedBox(height: 10),
                    _Card(children: [
                      VMenuItem(
                        icon: _iconBox(Icons.person_outline,
                            const Color(0xFFE8F0FF), AppColors.blue),
                        label: 'Edit profile',
                        onTap: () => _push(const EditProfileScreen()),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.alternate_email,
                            const Color(0xFFFFF3CC), AppColors.gold),
                        label: 'VeritasTag',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                              user.veritasTag != null
                                  ? '@${user.veritasTag}'
                                  : 'Not set',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.subText)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right,
                              color: AppColors.mutedText, size: 18),
                        ]),
                        onTap: () => _push(const VeritasTagScreen()),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.account_balance_outlined,
                            const Color(0xFFE8F5EF), AppColors.greenDark),
                        label: 'Payout accounts',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('${user.payoutAccounts.length} added',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.subText)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right,
                              color: AppColors.mutedText, size: 18),
                        ]),
                        onTap: () => _push(const PayoutMethodsScreen()),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    const VSectionLabel('Notifications'),
                    const SizedBox(height: 10),
                    _Card(children: [
                      _Toggle('Payment updates', _notifPayments,
                          (v) => setState(() => _notifPayments = v)),
                      _Toggle('Milestone activity', _notifMilestones,
                          (v) => setState(() => _notifMilestones = v)),
                      _Toggle('Dispute updates', _notifDisputes,
                          (v) => setState(() => _notifDisputes = v)),
                      _Toggle('Tips & promotions', _notifMarketing,
                          (v) => setState(() => _notifMarketing = v),
                          divider: false),
                    ]),
                    const SizedBox(height: 20),
                    const VSectionLabel('Security'),
                    const SizedBox(height: 10),
                    _Card(children: [
                      _Toggle('Face ID / Biometrics', _biometrics,
                          (v) => setState(() => _biometrics = v)),
                      VMenuItem(
                        icon: _iconBox(Icons.lock_outline,
                            const Color(0xFFFCE2E0), AppColors.redDark),
                        label: 'Transaction PIN',
                        onTap: () => _push(const PinFlowScreen(isChange: true)),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.key_outlined, AppColors.lightBg,
                            AppColors.darkText),
                        label: 'Change password',
                        onTap: () => _push(const ChangePasswordScreen()),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    const VSectionLabel('Preferences'),
                    const SizedBox(height: 10),
                    _Card(children: [
                      VMenuItem(
                        icon: _iconBox(Icons.language, const Color(0xFFE8F0FF),
                            AppColors.blue),
                        label: 'Language',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(user.language,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.subText)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right,
                              color: AppColors.mutedText, size: 18),
                        ]),
                        onTap: () => _push(const PreferencePickerScreen(
                            pickerKey: 'language')),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.palette_outlined,
                            const Color(0xFFFFF3CC), AppColors.gold),
                        label: 'Appearance',
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(user.appearance,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.subText)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right,
                              color: AppColors.mutedText, size: 18),
                        ]),
                        onTap: () => _push(const PreferencePickerScreen(
                            pickerKey: 'appearance')),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    const VSectionLabel('About'),
                    const SizedBox(height: 10),
                    _Card(children: [
                      VMenuItem(
                        icon: _iconBox(Icons.description_outlined,
                            AppColors.lightBg, AppColors.darkText),
                        label: 'Terms of service',
                        onTap: () => _push(const LegalScreen(showTerms: true)),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.shield_outlined, AppColors.lightBg,
                            AppColors.darkText),
                        label: 'Privacy policy',
                        onTap: () => _push(const LegalScreen(showTerms: false)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            _iconBox(Icons.info_outline, AppColors.lightBg,
                                AppColors.darkText),
                            const SizedBox(width: 13),
                            const Expanded(
                                child: Text('App version',
                                    style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText))),
                            const Text('1.0.0',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.subText)),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _Card(children: [
                      VMenuItem(
                        icon: _iconBox(Icons.logout, const Color(0xFFFCE2E0),
                            AppColors.redDark),
                        label: 'Log out',
                        labelColor: AppColors.redDark,
                        trailing: const SizedBox.shrink(),
                        onTap: () => _logout(),
                      ),
                      VMenuItem(
                        icon: _iconBox(Icons.delete_outline,
                            const Color(0xFFFCE2E0), AppColors.redDark),
                        label: 'Close account',
                        labelColor: AppColors.redDark,
                        trailing: const SizedBox.shrink(),
                        onTap: () => _closeAccount(),
                        showDivider: false,
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final ok = await showVConfirm(context,
        title: 'Log out?',
        body: 'You\'ll need to log in again to access your account.',
        confirmLabel: 'Log out');
    if (ok == true && mounted) {
      // Clear the stored refresh token too — otherwise splash's silent
      // auto-login would sign the user right back in on next launch.
      await ref.read(authServiceProvider).logout();

      ref.invalidate(userProvider);
      ref.invalidate(contractsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(notificationsProvider);
      ref.invalidate(supportMessagesProvider);
      ref.read(isLoggedInProvider.notifier).state = false;

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _closeAccount() async {
    final ok = await showVConfirm(context,
        title: 'Close account?',
        body:
            'This is permanent. All your data will be deleted. Contact support if you have active contracts.',
        confirmLabel: 'Close account');
    if (ok == true && mounted) {
      showVToast(
          context, 'Request submitted — support will contact you within 24h.');
    }
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool divider;
  const _Toggle(this.label, this.value, this.onChanged, {this.divider = true});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText))),
            Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.dark),
          ]),
        ),
        if (divider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1EFD6)),
      ]);
}
