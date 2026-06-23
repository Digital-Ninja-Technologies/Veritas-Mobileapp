import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'phone_input.dart';

const _countries = [
  ('Nigeria', '🇳🇬', '+234'),
  ('Ghana', '🇬🇭', '+233'),
  ('Kenya', '🇰🇪', '+254'),
  ('South Africa', '🇿🇦', '+27'),
  ('United Kingdom', '🇬🇧', '+44'),
  ('United States', '🇺🇸', '+1'),
  ('Canada', '🇨🇦', '+1'),
  ('Germany', '🇩🇪', '+49'),
  ('France', '🇫🇷', '+33'),
  ('Senegal', '🇸🇳', '+221'),
  ('Ivory Coast', '🇨🇮', '+225'),
  ('Uganda', '🇺🇬', '+256'),
  ('Tanzania', '🇹🇿', '+255'),
];

class CountryPickerScreen extends StatefulWidget {
  const CountryPickerScreen({super.key});

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  int _selectedIndex = 0;
  String _query = '';

  List<({String name, String flag, String code})> get _filtered {
    final filtered = _countries.where((c) =>
        c.$1.toLowerCase().contains(_query.toLowerCase())).toList();
    return filtered.map((c) => (name: c.$1, flag: c.$2, code: c.$3)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
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
                  const Text('Country of residence', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _ProgressBar(step: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search country…',
                  prefixIcon: Icon(Icons.search, color: AppColors.subText),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1EFD6)),
                itemBuilder: (_, i) {
                  final item = list[i];
                  final isSelected = item.name == _countries[_selectedIndex].$1;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = _countries.indexWhere((c) => c.$1 == item.name));
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Text(item.flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Text(item.code, style: const TextStyle(fontSize: 13, color: AppColors.subText)),
                          const SizedBox(width: 10),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.dark : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.dark,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: VButton(
                label: 'Continue',
                onTap: _selectedIndex >= 0
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhoneInputScreen(
                              country: _countries[_selectedIndex].$1,
                              dialCode: _countries[_selectedIndex].$3,
                            ),
                          ),
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;

  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              color: i < step ? AppColors.yellow : AppColors.lightBg,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      )),
    );
  }
}
