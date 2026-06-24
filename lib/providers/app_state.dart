import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models.dart';

// Auth state
final isLoggedInProvider = StateProvider<bool>((ref) => false);
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

// User
final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier() : super(const UserModel());

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

  void addFunds(double amount) {
    state = state.copyWith(clientBalance: state.clientBalance + amount);
  }

  void withdraw(double amount) {
    if (state.role == UserRole.freelancer) {
      state = state.copyWith(freelancerBalance: state.freelancerBalance - amount);
    } else {
      state = state.copyWith(clientBalance: state.clientBalance - amount);
    }
  }

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

  void creditBalance(double amount) {
    if (state.role == UserRole.freelancer) {
      state = state.copyWith(freelancerBalance: state.freelancerBalance + amount);
    } else {
      state = state.copyWith(clientBalance: state.clientBalance + amount);
    }
  }

  void updateTag(String tag) => state = state.copyWith(veritasTag: tag);

  void initFromOnboarding({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String phone,
    required String country,
    required String password,
  }) {
    state = state.copyWith(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      phone: phone,
      country: country,
      loginPassword: password,
    );
  }
}

// Contracts
final contractsProvider = StateNotifierProvider<ContractsNotifier, List<EscrowContract>>((ref) {
  return ContractsNotifier();
});

class ContractsNotifier extends StateNotifier<List<EscrowContract>> {
  ContractsNotifier() : super(seedContracts());

  void addContract(EscrowContract contract) {
    state = [...state, contract];
  }

  void updateMilestone(String contractId, String milestoneId, MilestoneModel updated) {
    state = state.map((c) {
      if (c.id != contractId) return c;
      final milestones = c.milestones.map((m) => m.id == milestoneId ? updated : m).toList();
      return c.copyWith(milestones: milestones);
    }).toList();
  }

  // Activates all contracts that were pending an invited user with this email.
  // Returns the count of contracts that were claimed.
  int claimContractsByEmail(String email) {
    final lower = email.toLowerCase();
    int count = 0;
    state = state.map((c) {
      if (c.inviteeEmail?.toLowerCase() == lower) {
        count++;
        return c.copyWith(clearInvitee: true);
      }
      return c;
    }).toList();
    return count;
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
