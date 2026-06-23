import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _firstCtrl = TextEditingController(text: user.firstName);
    _lastCtrl = TextEditingController(text: user.lastName);
    _emailCtrl = TextEditingController(text: user.email);
    _phoneCtrl = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

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
                  const Text('Edit profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(24)),
                            child: Center(
                              child: Text(
                                '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.darkText),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    VTextField(label: 'First name', controller: _firstCtrl, hint: 'First name'),
                    const SizedBox(height: 16),
                    VTextField(label: 'Last name', controller: _lastCtrl, hint: 'Last name'),
                    const SizedBox(height: 16),
                    VTextField(label: 'Email', controller: _emailCtrl, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    VTextField(label: 'Phone number', controller: _phoneCtrl, hint: '+234 800 000 0000', keyboardType: TextInputType.phone),
                    const SizedBox(height: 8),
                    const Row(children: [
                      Icon(Icons.info_outline, size: 14, color: AppColors.subText),
                      SizedBox(width: 6),
                      Text('Changes to email or phone require verification.', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                    ]),
                    const SizedBox(height: 28),
                    VButton(label: 'Save changes', onTap: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    ref.read(userProvider.notifier).updateProfile(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    Navigator.of(context).pop();
    showVToast(context, 'Profile updated');
  }
}
