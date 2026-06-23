enum UserRole { freelancer, client }

enum KycStatus { unverified, inReview, verified }

enum MilestoneStatus { pending, inProgress, submitted, inReview, changesRequested, released, inDispute, refunded }

enum DisputeStatus { open, underReview, resolved }

class UserModel {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String country;
  final String? veritasTag;
  final KycStatus kycStatus;
  final double freelancerBalance;
  final double clientBalance;
  final UserRole role;
  final String? transactionPin;
  final String? loginPassword;
  final bool twoFaEnabled;
  final bool biometricEnabled;
  final String language;
  final String appearance;
  final String displayCurrency;
  final List<PayoutAccount> payoutAccounts;
  final String? defaultPayoutId;

  const UserModel({
    this.firstName = 'Amaka',
    this.middleName = '',
    this.lastName = 'Okafor',
    this.email = 'amaka@example.com',
    this.phone = '+234 801 234 5678',
    this.country = 'Nigeria',
    this.veritasTag,
    this.kycStatus = KycStatus.unverified,
    this.freelancerBalance = 2350.00,
    this.clientBalance = 4500.00,
    this.role = UserRole.freelancer,
    this.transactionPin,
    this.loginPassword,
    this.twoFaEnabled = true,
    this.biometricEnabled = false,
    this.language = 'English',
    this.appearance = 'Light',
    this.displayCurrency = 'USD',
    this.payoutAccounts = const [
      PayoutAccount(
        id: 'gtb1',
        bankName: 'GTBank',
        accountNumber: '• • • • 4502',
        accountName: 'Amaka Okafor',
        currency: 'NGN',
        isDefault: true,
      ),
    ],
    this.defaultPayoutId = 'gtb1',
  });

  String get fullName =>
      [firstName, if (middleName.isNotEmpty) middleName, lastName].join(' ');

  double get balance => role == UserRole.freelancer ? freelancerBalance : clientBalance;

  UserModel copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phone,
    String? country,
    String? veritasTag,
    KycStatus? kycStatus,
    double? freelancerBalance,
    double? clientBalance,
    UserRole? role,
    String? transactionPin,
    String? loginPassword,
    bool? twoFaEnabled,
    bool? biometricEnabled,
    String? language,
    String? appearance,
    String? displayCurrency,
    List<PayoutAccount>? payoutAccounts,
    String? defaultPayoutId,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      veritasTag: veritasTag ?? this.veritasTag,
      kycStatus: kycStatus ?? this.kycStatus,
      freelancerBalance: freelancerBalance ?? this.freelancerBalance,
      clientBalance: clientBalance ?? this.clientBalance,
      role: role ?? this.role,
      transactionPin: transactionPin ?? this.transactionPin,
      loginPassword: loginPassword ?? this.loginPassword,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      language: language ?? this.language,
      appearance: appearance ?? this.appearance,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      payoutAccounts: payoutAccounts ?? this.payoutAccounts,
      defaultPayoutId: defaultPayoutId ?? this.defaultPayoutId,
    );
  }
}

class PayoutAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String currency;
  final bool isDefault;

  const PayoutAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.currency,
    this.isDefault = false,
  });

  PayoutAccount copyWith({bool? isDefault}) => PayoutAccount(
        id: id,
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        currency: currency,
        isDefault: isDefault ?? this.isDefault,
      );
}

class MilestoneModel {
  final String id;
  final String title;
  final double amount;
  MilestoneStatus status;
  String? deliveryNote;
  String? deliveryLink;
  String? changeNote;
  String? disputeRef;
  DisputeStatus? disputeStatus;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.amount,
    this.status = MilestoneStatus.pending,
    this.deliveryNote,
    this.deliveryLink,
    this.changeNote,
    this.disputeRef,
    this.disputeStatus,
  });

  MilestoneModel copyWith({
    MilestoneStatus? status,
    String? deliveryNote,
    String? deliveryLink,
    String? changeNote,
    String? disputeRef,
    DisputeStatus? disputeStatus,
  }) {
    return MilestoneModel(
      id: id,
      title: title,
      amount: amount,
      status: status ?? this.status,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      deliveryLink: deliveryLink ?? this.deliveryLink,
      changeNote: changeNote ?? this.changeNote,
      disputeRef: disputeRef ?? this.disputeRef,
      disputeStatus: disputeStatus ?? this.disputeStatus,
    );
  }
}

class EscrowContract {
  final String id;
  final String project;
  final String clientName;
  final String freelancerName;
  final String clientTag;
  final String freelancerTag;
  final double totalAmount;
  final List<MilestoneModel> milestones;
  final String avatarBg;
  final String avatarFg;
  final String initials;

  EscrowContract({
    required this.id,
    required this.project,
    required this.clientName,
    required this.freelancerName,
    required this.clientTag,
    required this.freelancerTag,
    required this.totalAmount,
    required this.milestones,
    required this.avatarBg,
    required this.avatarFg,
    required this.initials,
  });

  int get completedMilestones =>
      milestones.where((m) => m.status == MilestoneStatus.released).length;

  double get completedAmount => milestones
      .where((m) => m.status == MilestoneStatus.released)
      .fold(0.0, (sum, m) => sum + m.amount);

  double get progressPct =>
      milestones.isEmpty ? 0 : completedMilestones / milestones.length;

  String get statusBadge {
    if (milestones.every((m) => m.status == MilestoneStatus.released)) return 'Complete';
    if (milestones.any((m) => m.status == MilestoneStatus.inDispute)) return 'In dispute';
    if (milestones.any((m) => m.status == MilestoneStatus.inReview || m.status == MilestoneStatus.submitted)) return 'In review';
    if (milestones.any((m) => m.status == MilestoneStatus.changesRequested)) return 'Changes req.';
    return 'Active';
  }

  EscrowContract copyWith({List<MilestoneModel>? milestones}) {
    return EscrowContract(
      id: id,
      project: project,
      clientName: clientName,
      freelancerName: freelancerName,
      clientTag: clientTag,
      freelancerTag: freelancerTag,
      totalAmount: totalAmount,
      milestones: milestones ?? this.milestones,
      avatarBg: avatarBg,
      avatarFg: avatarFg,
      initials: initials,
    );
  }
}

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final String kind;
  final String? reference;
  final String? counterparty;
  final String? method;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.kind,
    this.reference,
    this.counterparty,
    this.method,
  });
}

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String kind;
  final DateTime time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.time,
    this.isRead = false,
  });
}

class SupportMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  const SupportMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

// Seed data

List<EscrowContract> seedContracts() => [
      EscrowContract(
        id: 'c1',
        project: 'Brand Identity & Collateral',
        clientName: 'Daniel Okafor',
        freelancerName: 'Amaka Okafor',
        clientTag: '@danielokafor',
        freelancerTag: '@amaka',
        totalAmount: 2500.00,
        avatarBg: '#E3ECFF',
        avatarFg: '#2D6BDB',
        initials: 'DO',
        milestones: [
          MilestoneModel(
            id: 'm1',
            title: 'Logo concepts (3 directions)',
            amount: 750.00,
            status: MilestoneStatus.released,
          ),
          MilestoneModel(
            id: 'm2',
            title: 'Final logo files + brand guide',
            amount: 750.00,
            status: MilestoneStatus.submitted,
            deliveryNote: 'All logo files are uploaded to the shared Drive folder. Includes SVG, PNG (transparent), and the brand guide PDF covering colors, typography, and usage guidelines.',
            deliveryLink: 'drive.google.com/share/brand-kit',
          ),
          MilestoneModel(
            id: 'm3',
            title: 'Business card & letterhead design',
            amount: 500.00,
            status: MilestoneStatus.pending,
          ),
          MilestoneModel(
            id: 'm4',
            title: 'Social media templates (12 posts)',
            amount: 500.00,
            status: MilestoneStatus.pending,
          ),
        ],
      ),
      EscrowContract(
        id: 'c2',
        project: 'Zara E-commerce Website',
        clientName: 'Zara Mensah',
        freelancerName: 'Amaka Okafor',
        clientTag: '@zaramensah',
        freelancerTag: '@amaka',
        totalAmount: 3800.00,
        avatarBg: '#FFF0F0',
        avatarFg: '#C0362C',
        initials: 'ZM',
        milestones: [
          MilestoneModel(
            id: 'm1',
            title: 'Wireframes & UX flow',
            amount: 800.00,
            status: MilestoneStatus.released,
          ),
          MilestoneModel(
            id: 'm2',
            title: 'Visual design system',
            amount: 1000.00,
            status: MilestoneStatus.released,
          ),
          MilestoneModel(
            id: 'm3',
            title: 'Homepage & product pages',
            amount: 1200.00,
            status: MilestoneStatus.changesRequested,
            changeNote: 'The product card layout doesn\'t match the mockup. The "Add to cart" button needs to be sticky at the bottom. Please also fix the mobile nav — it overflows on small screens.',
          ),
          MilestoneModel(
            id: 'm4',
            title: 'Checkout & payment integration',
            amount: 800.00,
            status: MilestoneStatus.pending,
          ),
        ],
      ),
      EscrowContract(
        id: 'c3',
        project: 'Podcast Production — 8 episodes',
        clientName: 'TechTalk Media',
        freelancerName: 'Amaka Okafor',
        clientTag: '@techtalk',
        freelancerTag: '@amaka',
        totalAmount: 1200.00,
        avatarBg: '#F0F8FF',
        avatarFg: '#008751',
        initials: 'TT',
        milestones: [
          MilestoneModel(id: 'm1', title: 'Episodes 1–4 edited & delivered', amount: 600.00, status: MilestoneStatus.released),
          MilestoneModel(id: 'm2', title: 'Episodes 5–8 edited & delivered', amount: 600.00, status: MilestoneStatus.pending),
        ],
      ),
    ];

List<TransactionModel> seedTransactions(UserRole role) {
  final now = DateTime.now();
  if (role == UserRole.freelancer) {
    return [
      TransactionModel(
        id: 't1',
        title: 'Milestone released',
        subtitle: 'Brand Identity — Logo concepts',
        amount: 750.00,
        isCredit: true,
        date: now.subtract(const Duration(days: 1)),
        kind: 'release',
        reference: 'ESC-001-M1',
        counterparty: 'Daniel Okafor',
        method: 'Escrow release',
      ),
      TransactionModel(
        id: 't2',
        title: 'Withdrawal to GTBank',
        subtitle: '• • • • 4502 · NGN',
        amount: 500.00,
        isCredit: false,
        date: now.subtract(const Duration(days: 2)),
        kind: 'withdraw',
        reference: 'WDR-7821',
        counterparty: 'GTBank',
        method: 'Bank transfer',
      ),
      TransactionModel(
        id: 't3',
        title: 'Milestone released',
        subtitle: 'Zara E-commerce — Wireframes',
        amount: 800.00,
        isCredit: true,
        date: now.subtract(const Duration(days: 5)),
        kind: 'release',
        reference: 'ESC-002-M1',
        counterparty: 'Zara Mensah',
        method: 'Escrow release',
      ),
      TransactionModel(
        id: 't4',
        title: 'Escrow funded',
        subtitle: 'Podcast Production — TechTalk Media',
        amount: 1200.00,
        isCredit: true,
        date: now.subtract(const Duration(days: 8)),
        kind: 'fund',
        reference: 'ESC-003',
        counterparty: 'TechTalk Media',
        method: 'Escrow',
      ),
    ];
  } else {
    return [
      TransactionModel(
        id: 't1',
        title: 'Funds released',
        subtitle: 'Brand Identity — Logo concepts',
        amount: 750.00,
        isCredit: false,
        date: now.subtract(const Duration(days: 1)),
        kind: 'release',
        reference: 'ESC-001-M1',
        counterparty: 'Amaka Okafor',
        method: 'Escrow release',
      ),
      TransactionModel(
        id: 't2',
        title: 'Escrow funded',
        subtitle: 'Brand Identity & Collateral',
        amount: 2500.00,
        isCredit: false,
        date: now.subtract(const Duration(days: 3)),
        kind: 'fund',
        reference: 'ESC-001',
        counterparty: 'Veritas escrow',
        method: 'Visa •••• 4242',
      ),
      TransactionModel(
        id: 't3',
        title: 'Funds added',
        subtitle: 'Via Visa card',
        amount: 5000.00,
        isCredit: true,
        date: now.subtract(const Duration(days: 7)),
        kind: 'topup',
        reference: 'TOP-5000',
        counterparty: 'Visa •••• 4242',
        method: 'Card',
      ),
    ];
  }
}

List<NotificationModel> seedNotifications(UserRole role) {
  final now = DateTime.now();
  return [
    NotificationModel(
      id: 'n1',
      title: 'Milestone submitted for review',
      subtitle: 'Amaka submitted "Final logo files" on Brand Identity.',
      kind: 'milestone',
      time: now.subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n2',
      title: 'Funds in escrow',
      subtitle: 'Your escrow for Podcast Production is now active.',
      kind: 'escrow',
      time: now.subtract(const Duration(days: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n3',
      title: 'Withdrawal processed',
      subtitle: '₦770,100 sent to GTBank • • • • 4502.',
      kind: 'withdraw',
      time: now.subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n4',
      title: 'Identity verified',
      subtitle: 'Your NIN slip has been verified. Limits increased.',
      kind: 'kyc',
      time: now.subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];
}
