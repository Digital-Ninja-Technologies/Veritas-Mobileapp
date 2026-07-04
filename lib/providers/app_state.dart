import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/escrow_service.dart';
import '../services/token_storage.dart';
import '../services/wallet_service.dart';

// Networking / auth / wallet / escrow services
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(tokenStorageProvider)));
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);
final walletServiceProvider = Provider<WalletService>((ref) => WalletService(ref.watch(apiClientProvider)));
final escrowServiceProvider = Provider<EscrowService>((ref) => EscrowService(ref.watch(apiClientProvider)));

/// Fetches the real wallet balance and mirrors it into both
/// freelancerBalance/clientBalance — the backend has a single wallet per
/// user regardless of the local freelancer/client view toggle, so both
/// fields always reflect the same real value after this runs.
Future<void> refreshWalletBalance(WidgetRef ref) async {
  final wallet = await ref.read(walletServiceProvider).getWallet();
  ref.read(userProvider.notifier).setWalletBalanceKobo(wallet.balanceKobo);
}

/// Fetches the caller's real escrows (as client or freelancer) from the
/// backend and replaces the local contracts list.
Future<void> refreshContracts(WidgetRef ref) => ref.read(contractsProvider.notifier).loadFromApi();

// Auth state
final isLoggedInProvider = StateProvider<bool>((ref) => false);
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

// User
final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(const UserModel());

  /// Replaces user state wholesale with the result of a register/login/me
  /// call — local-only fields (role, KYC, payout accounts) fall back to
  /// UserModel's defaults since the backend doesn't track them.
  void applyAuthResult(UserModel user) => state = user;

  /// Mirrors the real backend wallet balance (kobo, NGN) into the local
  /// dual-balance fields via the app's existing USD<->NGN fxRate, so
  /// `state.balance` and every screen reading it keep working unchanged.
  void setWalletBalanceKobo(int kobo) {
    final usd = (kobo / 100) / fxRate;
    state = state.copyWith(freelancerBalance: usd, clientBalance: usd);
  }

  void reset() => state = const UserModel();

  void setRole(UserRole role) => state = state.copyWith(role: role);
  void setKyc(KycStatus status) => state = state.copyWith(kycStatus: status);
  void setVeritasTag(String tag) => state = state.copyWith(veritasTag: tag);
  void updateProfile({String? firstName, String? middleName, String? lastName, String? email, String? phone}) {
    state = state.copyWith(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  void setPin(String pin) => state = state.copyWith(transactionPin: pin);
  void setPassword(String pwd) => state = state.copyWith(loginPassword: pwd);
  void setTwoFa(bool v) => state = state.copyWith(twoFaEnabled: v);
  void setBiometric(bool v) => state = state.copyWith(biometricEnabled: v);
  void setLanguage(String v) => state = state.copyWith(language: v);
  void setAppearance(String v) => state = state.copyWith(appearance: v);
  void setDisplayCurrency(String v) => state = state.copyWith(displayCurrency: v);

  void creditFreelancer(double amount) {
    state = state.copyWith(freelancerBalance: state.freelancerBalance + amount);
  }

  void debitClient(double amount) {
    state = state.copyWith(clientBalance: state.clientBalance - amount);
  }

  void addPayoutAccount(PayoutAccount account) {
    final updated = [...state.payoutAccounts, account];
    state = state.copyWith(payoutAccounts: updated);
  }

  void setDefaultPayout(String id) {
    final updated = state.payoutAccounts.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    state = state.copyWith(payoutAccounts: updated, defaultPayoutId: id);
  }

  void removePayoutAccount(String id) {
    final updated = state.payoutAccounts.where((a) => a.id != id).toList();
    state = state.copyWith(payoutAccounts: updated);
  }

  void updateTag(String tag) => state = state.copyWith(veritasTag: tag);
}

// Contracts
final contractsProvider = StateNotifierProvider<ContractsNotifier, List<EscrowContract>>((ref) {
  return ContractsNotifier(ref);
});

/// Backend milestone status → local display status. "approved" is transient
/// (approve+release happen in one backend call) so it's rarely observed at
/// rest; "rejected" has no reachable path since there's no reject endpoint.
MilestoneStatus _mapMilestoneStatus(String backend) {
  switch (backend) {
    case 'delivered':
      return MilestoneStatus.submitted;
    case 'released':
      return MilestoneStatus.released;
    default:
      return MilestoneStatus.pending;
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((w) => w[0]).join().toUpperCase();
}

class ContractsNotifier extends StateNotifier<List<EscrowContract>> {
  final Ref _ref;
  ContractsNotifier(this._ref) : super([]);

  /// Fetches every escrow the caller is a party to (as client or freelancer)
  /// and replaces the local list. Resolves the counterparty's display name
  /// per contract via AuthService's cached /users/:id lookup.
  Future<void> loadFromApi() async {
    final escrowService = _ref.read(escrowServiceProvider);
    final authService = _ref.read(authServiceProvider);
    final me = _ref.read(userProvider);

    final remoteEscrows = await escrowService.listEscrows();
    final contracts = await Future.wait(remoteEscrows.map((e) async {
      final isClient = e.clientId == me.id;
      final counterpartId = isClient ? e.freelancerId : e.clientId;
      final counterpartName = await authService.publicNameFor(counterpartId);
      final milestones = await escrowService.listMilestones(e.id);

      return EscrowContract(
        id: e.id,
        project: e.title,
        clientName: isClient ? me.fullName : counterpartName,
        freelancerName: isClient ? counterpartName : me.fullName,
        clientTag: '',
        freelancerTag: '',
        totalAmount: (e.amountKobo / 100) / fxRate,
        milestones: milestones
            .map((m) => MilestoneModel(
                  id: m.id,
                  title: m.title,
                  amount: (m.amountKobo / 100) / fxRate,
                  status: _mapMilestoneStatus(m.status),
                ))
            .toList(),
        avatarBg: '#E3ECFF',
        avatarFg: '#2D6BDB',
        initials: _initialsFor(counterpartName),
        clientId: e.clientId,
        freelancerId: e.freelancerId,
        escrowStatus: e.status,
      );
    }));

    state = contracts;
  }

  void updateMilestone(String contractId, String milestoneId, MilestoneModel updated) {
    state = state.map((c) {
      if (c.id != contractId) return c;
      final milestones = c.milestones.map((m) => m.id == milestoneId ? updated : m).toList();
      return c.copyWith(milestones: milestones);
    }).toList();
  }
}

// Transactions
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
  final role = ref.watch(userProvider).role;
  return TransactionsNotifier(role);
});

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier(UserRole role) : super(seedTransactions(role));

  void addTransaction(TransactionModel tx) {
    state = [tx, ...state];
  }
}

// Notifications
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  final role = ref.watch(userProvider).role;
  return NotificationsNotifier(role);
});

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier(UserRole role) : super(seedNotifications(role));

  void markAllRead() {
    state = state.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      subtitle: n.subtitle,
      kind: n.kind,
      time: n.time,
      isRead: true,
    )).toList();
  }

  void addPendingContractNotif(int count, String firstName) {
    final msg = count == 1
        ? '$firstName, you have an escrow contract waiting for you.'
        : '$firstName, you have $count escrow contracts waiting for you.';
    state = [
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: count == 1 ? 'Escrow contract received' : '$count escrow contracts received',
        subtitle: msg,
        kind: 'escrow',
        time: DateTime.now(),
        isRead: false,
      ),
      ...state,
    ];
  }

  bool get hasUnread => state.any((n) => !n.isRead);
}

final hasUnreadNotifsProvider = Provider<bool>((ref) {
  return ref.watch(notificationsProvider.notifier).hasUnread;
});

// Support chat
final supportMessagesProvider = StateNotifierProvider<SupportChatNotifier, List<SupportMessage>>((ref) {
  return SupportChatNotifier();
});

class SupportChatNotifier extends StateNotifier<List<SupportMessage>> {
  SupportChatNotifier() : super([
    SupportMessage(
      text: 'Hi! I\'m Tomi from Veritas Support. How can I help you today? You can ask about your escrow, a payment, or raise a dispute.',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ]);

  void addMessage(SupportMessage msg) => state = [...state, msg];
  void clearMessages() => state = [
    SupportMessage(
      text: 'Hi! I\'m Tomi from Veritas Support. How can I help you today? You can ask about your escrow, a payment, or raise a dispute.',
      isUser: false,
      time: DateTime.now(),
    ),
  ];
}

// Selected contract
final selectedContractIdProvider = StateProvider<String?>((ref) => null);

final selectedContractProvider = Provider<EscrowContract?>((ref) {
  final id = ref.watch(selectedContractIdProvider);
  if (id == null) return null;
  final contracts = ref.watch(contractsProvider);
  try {
    return contracts.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

// FX rate
const double fxRate = 1540.20;

String formatUSD(double amount) {
  final neg = amount < 0;
  final abs = amount.abs();
  final parts = abs.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '${neg ? '-' : ''}\$$whole.${parts[1]}';
}

String formatNGN(double amount) {
  final parts = (amount * fxRate).toStringAsFixed(0);
  final formatted = parts.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '₦$formatted';
}
