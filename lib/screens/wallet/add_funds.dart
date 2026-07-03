import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../services/api_client.dart';
import '../../services/wallet_service.dart';
import '../../widgets/common.dart';

/// Real funding is a bank transfer to the wallet's dedicated Nomba virtual
/// account — there's no card/crypto path on the backend, and the balance
/// only updates once Nomba's webhook confirms the transfer (asynchronous,
/// not something this screen can wait for).
class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  FundingDetails? _details;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _error = null; _details = null; });
    try {
      final details = await ref.read(walletServiceProvider).fundWallet();
      if (mounted) setState(() => _details = details);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load your funding details. Please try again.');
    }
  }

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
                  const Text('Add funds', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.subText2)),
              const SizedBox(height: 20),
              VButton(label: 'Try again', onTap: _load),
            ],
          ),
        ),
      );
    }

    if (_details == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.dark));
    }

    final details = _details!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transfer to your Veritas account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkText, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text(
            'Send any amount from your bank app to the account below. Your Veritas balance updates automatically once the transfer is confirmed — usually within a few minutes.',
            style: TextStyle(fontSize: 14, color: AppColors.subText2, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bank', style: TextStyle(fontSize: 13, color: Color(0xFFC9C6A6))),
                const SizedBox(height: 4),
                Text(details.bankName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 18),
                const Text('Account number', style: TextStyle(fontSize: 13, color: Color(0xFFC9C6A6))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(details.accountNumber, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: details.accountNumber));
                        showVToast(context, 'Account number copied');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.copy, color: AppColors.yellow, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(children: [
            Icon(Icons.info_outline, size: 14, color: AppColors.subText),
            SizedBox(width: 6),
            Expanded(child: Text('This account is yours alone — reuse it any time you want to add funds.', style: TextStyle(fontSize: 12.5, color: AppColors.subText))),
          ]),
          const SizedBox(height: 28),
          VButton(label: 'Done', onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
