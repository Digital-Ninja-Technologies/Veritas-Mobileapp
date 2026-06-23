import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import 'personal_details.dart';

class PhoneInputScreen extends StatefulWidget {
  final String country;
  final String dialCode;

  const PhoneInputScreen({super.key, required this.country, required this.dialCode});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _ctrl = TextEditingController();

  bool get _valid => _ctrl.text.replaceAll(RegExp(r'\D'), '').length >= 7;

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
              Row(
                children: [
                  const VBackButton(),
                  const SizedBox(width: 14),
                  const Text('Phone number', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
              const SizedBox(height: 20),
              _ProgressBar(step: 2),
              const SizedBox(height: 32),
              const Text('Your phone number', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                'We\'ll send a verification code to this number.',
                style: const TextStyle(fontSize: 14, color: AppColors.subText2),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
                      ),
                      child: Text(
                        widget.dialCode,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.darkText),
                        decoration: const InputDecoration(
                          hintText: '800 000 0000',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Country: ${widget.country}',
                style: const TextStyle(fontSize: 13, color: AppColors.subText),
              ),
              const Spacer(),
              VButton(
                label: 'Continue',
                onTap: _valid
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PersonalDetailsScreen(
                              country: widget.country,
                              phone: '${widget.dialCode} ${_ctrl.text}',
                            ),
                          ),
                        )
                    : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
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
