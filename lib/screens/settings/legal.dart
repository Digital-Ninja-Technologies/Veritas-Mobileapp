import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class LegalScreen extends StatelessWidget {
  final bool showTerms;
  const LegalScreen({super.key, this.showTerms = true});

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
                  Text(showTerms ? 'Terms of Service' : 'Privacy Policy', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: showTerms ? _termsContent() : _privacyContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _termsContent() => [
    _LastUpdated('June 2025'),
    _Section('1. Acceptance of Terms', 'By using Veritas, you agree to be bound by these Terms of Service. If you do not agree, please do not use the platform. Veritas is a payment escrow platform operated by Veritas Technologies Ltd.'),
    _Section('2. Escrow Services', 'Veritas provides escrow services to facilitate secure payments between clients and freelancers. Funds held in escrow are not accessible to Veritas and are released only per the contractual milestones agreed by both parties.'),
    _Section('3. Fees', 'Veritas charges a platform fee of 1.5% on contract value funded by clients, and a 0.9% withdrawal fee on amounts withdrawn. Fees are displayed transparently before any transaction is confirmed.'),
    _Section('4. Disputes', 'In the event of a dispute, Veritas\'s resolution team will review submitted evidence from both parties and make a binding decision within 48 hours. Veritas\'s decision is final.'),
    _Section('5. Prohibited Conduct', 'You may not use Veritas for illegal activities, money laundering, financing of terrorism, or any activity that violates applicable laws. Violations will result in immediate account suspension and reporting to relevant authorities.'),
    _Section('6. Account Termination', 'Veritas reserves the right to suspend or terminate accounts that violate these terms. Users may close their accounts at any time, provided there are no active escrow contracts or pending disputes.'),
    _Section('7. Limitation of Liability', 'Veritas is not liable for indirect, incidental, or consequential damages arising from use of the platform. Our total liability is limited to the fees paid by you in the 30 days preceding the claim.'),
    _Section('8. Governing Law', 'These terms are governed by the laws of the Federal Republic of Nigeria. Any disputes shall be resolved in the courts of Lagos State.'),
    _ContactSection(),
  ];

  List<Widget> _privacyContent() => [
    _LastUpdated('June 2025'),
    _Section('1. Information We Collect', 'We collect information you provide directly (name, email, phone, government ID for KYC), information generated through your use of the platform (transaction history, contract data), and technical information (device type, IP address, usage data).'),
    _Section('2. How We Use Your Data', 'We use your data to provide and improve our services, verify your identity (KYC), process transactions, detect fraud, comply with legal obligations, and communicate important updates.'),
    _Section('3. Data Sharing', 'We do not sell your personal data. We share data only with: licensed banking partners to process payments; regulatory authorities when legally required; and identity verification providers for KYC compliance.'),
    _Section('4. Data Security', 'We use industry-standard encryption (AES-256 at rest, TLS 1.3 in transit) to protect your data. Access to personal data is restricted to authorized personnel on a need-to-know basis.'),
    _Section('5. Your Rights', 'You have the right to access, correct, or delete your personal data. You may also withdraw consent for non-essential processing. To exercise these rights, contact us at info@useveritasapp.com.'),
    _Section('6. Cookies', 'Our mobile application does not use cookies. We use anonymized analytics to understand usage patterns and improve the user experience.'),
    _Section('7. Data Retention', 'We retain your data for as long as your account is active, plus 7 years thereafter for regulatory compliance. You may request deletion of non-regulatory data at any time.'),
    _Section('8. Children\'s Privacy', 'Veritas is not directed at individuals under 18. We do not knowingly collect data from minors.'),
    _ContactSection(),
  ];
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated(this.date);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text('Last updated: $date', style: const TextStyle(fontSize: 12.5, color: AppColors.subText, fontStyle: FontStyle.italic)),
  );
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkText)),
      const SizedBox(height: 6),
      Text(body, style: const TextStyle(fontSize: 13.5, color: AppColors.subText2, height: 1.6)),
    ]),
  );
}

class _ContactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Questions?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText)),
      SizedBox(height: 6),
      Text('Contact us at info@useveritasapp.com\nVeritas Technologies Ltd, Lagos, Nigeria', style: TextStyle(fontSize: 13, color: AppColors.subText2, height: 1.6)),
    ]),
  );
}
