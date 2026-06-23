import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class PreferencePickerScreen extends ConsumerWidget {
  final String pickerKey; // 'language' or 'appearance'

  const PreferencePickerScreen({super.key, required this.pickerKey});

  bool get isAppearance => pickerKey == 'appearance';

  String get title => isAppearance ? 'Appearance' : 'Language';

  List<String> get options => isAppearance
      ? ['Light', 'Dark', 'System']
      : ['English', 'Français', 'Português', 'Kiswahili', 'Yorùbá', 'Hausa'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final current = isAppearance ? user.appearance : user.language;

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
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: options.asMap().entries.map((e) {
                      final i = e.key;
                      final option = e.value;
                      final selected = option == current;
                      final isLast = i == options.length - 1;

                      return GestureDetector(
                        onTap: () {
                          if (isAppearance) {
                            ref.read(userProvider.notifier).setAppearance(option);
                          } else {
                            ref.read(userProvider.notifier).setLanguage(option);
                          }
                          Navigator.of(context).pop();
                          showVToast(context, 'Preference saved');
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkText),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(Icons.check, color: AppColors.greenDark, size: 20),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1EFD6)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
