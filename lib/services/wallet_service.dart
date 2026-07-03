import 'api_client.dart';

class WalletModel {
  final String id;
  final int balanceKobo;
  final String accountNumber;
  final String bankName;

  WalletModel({
    required this.id,
    required this.balanceKobo,
    this.accountNumber = '',
    this.bankName = '',
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id'] as String,
        balanceKobo: (json['balance_kobo'] as num).toInt(),
        accountNumber: (json['nomba_virtual_account_number'] as String?) ?? '',
        bankName: (json['nomba_virtual_bank_name'] as String?) ?? '',
      );
}

/// The virtual account details to transfer into, returned by POST
/// /wallet/fund. Crediting happens later, asynchronously, when Nomba's
/// webhook fires — this is just where to send the money.
class FundingDetails {
  final String accountNumber;
  final String bankName;
  final String accountRef;

  FundingDetails({required this.accountNumber, required this.bankName, required this.accountRef});

  factory FundingDetails.fromJson(Map<String, dynamic> json) => FundingDetails(
        accountNumber: (json['account_number'] as String?) ?? '',
        bankName: (json['bank_name'] as String?) ?? '',
        accountRef: (json['account_ref'] as String?) ?? '',
      );
}

class WalletService {
  final ApiClient api;
  WalletService(this.api);

  Future<WalletModel> getWallet() async {
    final json = await api.get('/wallet');
    return WalletModel.fromJson(json!['data'] as Map<String, dynamic>);
  }

  Future<FundingDetails> fundWallet() async {
    final json = await api.post('/wallet/fund');
    return FundingDetails.fromJson(json!['data'] as Map<String, dynamic>);
  }

  /// Throws ApiException (e.g. "insufficient wallet balance") on failure.
  Future<void> withdraw({
    required int amountKobo,
    required String bankCode,
    required String accountNumber,
    required String accountName,
  }) async {
    await api.post('/wallet/withdraw', body: {
      'amount_kobo': amountKobo,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'account_name': accountName,
    });
  }
}
