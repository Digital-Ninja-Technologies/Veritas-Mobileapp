import 'api_client.dart';

class MilestoneInput {
  final String title;
  final String description;
  final double percentage;
  MilestoneInput({required this.title, this.description = '', required this.percentage});
}

class RemoteEscrow {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String freelancerId;
  final int amountKobo;
  final int platformFeeKobo;
  final String status;
  final String paymentMethod;
  final DateTime deadlineAt;
  final DateTime createdAt;
  final DateTime? fundedAt;
  final DateTime? completedAt;

  RemoteEscrow({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.freelancerId,
    required this.amountKobo,
    required this.platformFeeKobo,
    required this.status,
    required this.paymentMethod,
    required this.deadlineAt,
    required this.createdAt,
    this.fundedAt,
    this.completedAt,
  });

  factory RemoteEscrow.fromJson(Map<String, dynamic> json) => RemoteEscrow(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        clientId: json['client_id'] as String,
        freelancerId: json['freelancer_id'] as String,
        amountKobo: (json['amount_kobo'] as num).toInt(),
        platformFeeKobo: (json['platform_fee_kobo'] as num?)?.toInt() ?? 0,
        status: json['status'] as String,
        paymentMethod: (json['payment_method'] as String?) ?? 'naira',
        deadlineAt: DateTime.parse(json['deadline_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        fundedAt: json['funded_at'] != null ? DateTime.parse(json['funded_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      );
}

/// Backend milestone status is one of: pending, delivered, approved,
/// rejected, released. ("approved" is transient — approve+release happen in
/// one request — so it's rarely, if ever, observed at rest.)
class RemoteMilestone {
  final String id;
  final String escrowId;
  final String title;
  final String description;
  final int amountKobo;
  final String status;
  final String deliveryNote;
  final String deliveryLink;
  final String revisionNote;
  final DateTime? dueAt;

  RemoteMilestone({
    required this.id,
    required this.escrowId,
    required this.title,
    required this.description,
    required this.amountKobo,
    required this.status,
    this.deliveryNote = '',
    this.deliveryLink = '',
    this.revisionNote = '',
    this.dueAt,
  });

  factory RemoteMilestone.fromJson(Map<String, dynamic> json) => RemoteMilestone(
        id: json['id'] as String,
        escrowId: json['escrow_id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        amountKobo: (json['amount_kobo'] as num).toInt(),
        status: json['status'] as String,
        deliveryNote: (json['delivery_note'] as String?) ?? '',
        deliveryLink: (json['delivery_link'] as String?) ?? '',
        revisionNote: (json['revision_note'] as String?) ?? '',
        dueAt: json['due_at'] != null ? DateTime.parse(json['due_at'] as String) : null,
      );
}

/// Backend disputes are escrow-level (one reason string, no per-milestone
/// targeting) — status is one of: open, reviewing, resolved.
class RemoteDispute {
  final String id;
  final String escrowId;
  final String raisedBy;
  final String reason;
  final String status;
  final String? resolution;
  final String? adminNote;

  RemoteDispute({
    required this.id,
    required this.escrowId,
    required this.raisedBy,
    required this.reason,
    required this.status,
    this.resolution,
    this.adminNote,
  });

  factory RemoteDispute.fromJson(Map<String, dynamic> json) => RemoteDispute(
        id: json['id'] as String,
        escrowId: json['escrow_id'] as String,
        raisedBy: json['raised_by'] as String,
        reason: json['reason'] as String,
        status: json['status'] as String,
        resolution: json['resolution'] as String?,
        adminNote: json['admin_note'] as String?,
      );
}

class RemoteTransaction {
  final String id;
  final String? escrowId;
  final String? milestoneId;
  final String? walletId;
  final String type;
  final int amountKobo;
  final String status;
  final DateTime createdAt;

  RemoteTransaction({
    required this.id,
    this.escrowId,
    this.milestoneId,
    this.walletId,
    required this.type,
    required this.amountKobo,
    required this.status,
    required this.createdAt,
  });

  factory RemoteTransaction.fromJson(Map<String, dynamic> json) => RemoteTransaction(
        id: json['id'] as String,
        escrowId: json['escrow_id'] as String?,
        milestoneId: json['milestone_id'] as String?,
        walletId: json['wallet_id'] as String?,
        type: json['type'] as String,
        amountKobo: (json['amount_kobo'] as num).toInt(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class EscrowService {
  final ApiClient api;
  EscrowService(this.api);

  Future<List<RemoteEscrow>> listEscrows({String? status}) async {
    final path = status != null && status.isNotEmpty ? '/escrows?status=$status' : '/escrows';
    final json = await api.get(path);
    final data = (json?['data'] as List?) ?? [];
    return data.map((e) => RemoteEscrow.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RemoteEscrow> getEscrow(String id) async {
    final json = await api.get('/escrows/$id');
    return RemoteEscrow.fromJson(json!['data'] as Map<String, dynamic>);
  }

  /// Creates a project. amountKobo is debited from the client's wallet
  /// synchronously — throws ApiException("insufficient wallet balance...")
  /// if the balance is too low, or a clear "no account found for <email>"
  /// error if the freelancer hasn't signed up yet (the backend requires an
  /// existing account, there's no pending-invite concept).
  Future<RemoteEscrow> createEscrow({
    required String title,
    String description = '',
    required String freelancerEmail,
    required int amountKobo,
    required DateTime deadlineAt,
    List<MilestoneInput> milestones = const [],
  }) async {
    final json = await api.post('/escrows', body: {
      'title': title,
      'description': description,
      'freelancer_email': freelancerEmail,
      'amount_kobo': amountKobo,
      'payment_method': 'naira',
      'deadline_at': deadlineAt.toUtc().toIso8601String(),
      if (milestones.isNotEmpty)
        'milestones': milestones
            .map((m) => {'title': m.title, 'description': m.description, 'percentage': m.percentage})
            .toList(),
    });
    return RemoteEscrow.fromJson(json!['data'] as Map<String, dynamic>);
  }

  Future<void> cancelEscrow(String id) => api.post('/escrows/$id/cancel');

  /// Final release for escrows with no milestones — pays the freelancer's
  /// wallet in full. No body needed.
  Future<void> approveFinalRelease(String id) => api.post('/escrows/$id/release');

  Future<List<RemoteMilestone>> listMilestones(String escrowId) async {
    final json = await api.get('/escrows/$escrowId/milestones');
    final data = (json?['data'] as List?) ?? [];
    return data.map((m) => RemoteMilestone.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<List<RemoteTransaction>> listTransactions(String escrowId) async {
    final json = await api.get('/escrows/$escrowId/transactions');
    final data = (json?['data'] as List?) ?? [];
    return data.map((t) => RemoteTransaction.fromJson(t as Map<String, dynamic>)).toList();
  }

  /// Freelancer marks a milestone delivered, optionally attaching a note
  /// and/or a link to the delivered work.
  Future<void> markMilestoneDelivered(String milestoneId, {String? note, String? link}) => api.post(
        '/milestones/$milestoneId/deliver',
        body: {
          if (note != null && note.isNotEmpty) 'note': note,
          if (link != null && link.isNotEmpty) 'link': link,
        },
      );

  /// Client approves — releases the milestone's share into the freelancer's
  /// wallet. No body needed.
  Future<void> approveMilestone(String milestoneId) => api.post('/milestones/$milestoneId/approve');

  /// Client requests changes on a delivered milestone, sending it back to
  /// the freelancer for redelivery.
  Future<void> rejectMilestone(String milestoneId, String note) =>
      api.post('/milestones/$milestoneId/reject', body: {'note': note});

  Future<RemoteDispute> raiseDispute(String escrowId, String reason) async {
    final json = await api.post('/escrows/$escrowId/dispute', body: {'reason': reason});
    return RemoteDispute.fromJson(json!['data'] as Map<String, dynamic>);
  }

  Future<RemoteDispute?> getDispute(String escrowId) async {
    final json = await api.get('/escrows/$escrowId/dispute');
    final data = json?['data'];
    if (data == null) return null;
    return RemoteDispute.fromJson(data as Map<String, dynamic>);
  }

  /// Global activity feed — every transaction across the user's escrows and
  /// wallet, most recent first.
  Future<List<RemoteTransaction>> listMyTransactions() async {
    final json = await api.get('/transactions');
    final data = (json?['data'] as List?) ?? [];
    return data.map((t) => RemoteTransaction.fromJson(t as Map<String, dynamic>)).toList();
  }
}
