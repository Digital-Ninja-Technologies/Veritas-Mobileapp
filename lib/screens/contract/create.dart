import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/escrow_service.dart';
import '../../widgets/common.dart';

// ─── Data classes ────────────────────────────────────────────────────────────

enum _CStep { details, milestones, review }

class _FreelancerEntry {
  final String tag;
  final String handle;
  final String name;
  final String email;
  final String avBg;
  final String avFg;
  final double? rating;
  final bool verified;
  final String skill;
  const _FreelancerEntry({
    required this.tag,
    required this.handle,
    required this.name,
    required this.email,
    required this.avBg,
    required this.avFg,
    this.rating,
    required this.verified,
    required this.skill,
  });
  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .take(2)
      .join()
      .toUpperCase();
}

class _MS {
  String id;
  String title;
  String due;
  double amt;
  _MS(
      {required this.id,
      required this.title,
      required this.due,
      required this.amt});
}

// ─── Constants ───────────────────────────────────────────────────────────────

const _kDirectory = [
  _FreelancerEntry(
      tag: 'adundesigns',
      handle: '@adun.designs',
      name: 'Adunni Adeyemi',
      email: 'adunni@adun.designs',
      avBg: '#E3ECFF',
      avFg: '#2D6BDB',
      rating: 4.9,
      verified: true,
      skill: 'Brand & visual design'),
  _FreelancerEntry(
      tag: 'danielokafor',
      handle: '@danielokafor',
      name: 'Daniel Okafor',
      email: 'daniel@okaforstudio.co',
      avBg: '#E7DBFF',
      avFg: '#6E3FCF',
      rating: 4.8,
      verified: true,
      skill: 'Illustration & cover art'),
  _FreelancerEntry(
      tag: 'zaramensah',
      handle: '@zaramensah',
      name: 'Zara Mensah',
      email: 'zara@zaratech.io',
      avBg: '#D7EEFF',
      avFg: '#2D6BDB',
      rating: 5.0,
      verified: true,
      skill: 'Frontend development'),
  _FreelancerEntry(
      tag: 'kojoasante',
      handle: '@kojoasante',
      name: 'Kojo Asante',
      email: 'kojo@kojodesign.gh',
      avBg: '#FFE7C2',
      avFg: '#C97A00',
      rating: 4.7,
      verified: false,
      skill: 'Product design'),
  _FreelancerEntry(
      tag: 'lindaeze',
      handle: '@lindaeze',
      name: 'Linda Eze',
      email: 'linda@ezecreative.com',
      avBg: '#D9F2E3',
      avFg: '#008751',
      rating: 4.9,
      verified: true,
      skill: 'Copywriting & content'),
];

const _kBaseCats = ['Design', 'Development', 'Writing', 'Marketing', 'Video'];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class CreateEscrowScreen extends ConsumerStatefulWidget {
  const CreateEscrowScreen({super.key});
  @override
  ConsumerState<CreateEscrowScreen> createState() => _CreateEscrowScreenState();
}

class _CreateEscrowScreenState extends ConsumerState<CreateEscrowScreen> {
  _CStep _step = _CStep.details;
  bool _submitting = false;

  // Step 1
  final _projectCtrl = TextEditingController();
  _FreelancerEntry? _freelancer;
  String _category = 'Design';
  final List<String> _customCats = [];

  // Step 2
  final List<_MS> _milestones = [
    _MS(id: 'cm1', title: 'Milestone 1', due: '', amt: 0),
  ];

  double get _total => _milestones.fold(0.0, (s, m) => s + m.amt);
  bool get _step1Valid =>
      _projectCtrl.text.trim().isNotEmpty &&
      _freelancer != null &&
      _freelancer!.email.isNotEmpty;
  bool get _step2Valid => _milestones.isNotEmpty && _total > 0;
  int get _stepNum => _step == _CStep.details
      ? 1
      : _step == _CStep.milestones
          ? 2
          : 3;
  String get _headerTitle =>
      _step == _CStep.review ? 'Review & fund' : 'New escrow';
  List<String> get _allCats => [..._kBaseCats, ..._customCats];

  @override
  void dispose() {
    _projectCtrl.dispose();
    super.dispose();
  }

  Color _hex(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  void _back() {
    if (_step == _CStep.details)
      Navigator.of(context).pop();
    else if (_step == _CStep.milestones)
      setState(() => _step = _CStep.details);
    else
      setState(() => _step = _CStep.milestones);
  }

  void _next() {
    if (_step == _CStep.details) {
      if (!_step1Valid) {
        showVToast(context, 'Add a project title and freelancer');
        return;
      }
      setState(() => _step = _CStep.milestones);
    } else if (_step == _CStep.milestones) {
      if (!_step2Valid) {
        showVToast(context, 'Add at least one milestone with an amount');
        return;
      }
      setState(() => _step = _CStep.review);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _buildCurrentStep(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    final bar2 =
        _step != _CStep.details ? AppColors.yellow : const Color(0x20372F01);
    final bar3 =
        _step == _CStep.review ? AppColors.yellow : const Color(0x20372F01);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.chevron_left,
                  color: AppColors.darkText, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(_headerTitle,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText)),
                Text('Step $_stepNum of 3',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.subText)),
              ])),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border)),
              child:
                  const Icon(Icons.close, color: AppColors.subText, size: 17),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _Bar(AppColors.yellow)),
          const SizedBox(width: 6),
          Expanded(child: _Bar(bar2)),
          const SizedBox(width: 6),
          Expanded(child: _Bar(bar3)),
        ]),
      ]),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _CStep.details:
        return _StepDetails(key: const ValueKey('d'), state: this);
      case _CStep.milestones:
        return _StepMilestones(key: const ValueKey('m'), state: this);
      case _CStep.review:
        return _StepReview(key: const ValueKey('r'), state: this);
    }
  }

  // ─── Freelancer picker ────────────────────────────────────────────────────

  /// Confirms `email` belongs to a registered Veritas account before letting
  /// the caller select it — the backend rejects escrow creation for an
  /// unregistered freelancer, so we surface that up front instead of only at
  /// the funding step. Returns the resolved profile, or null (having already
  /// shown a toast) if the email can't be used.
  Future<PublicProfile?> _validateFreelancerEmail(String email) async {
    final me = ref.read(userProvider);
    if (me.email.trim().toLowerCase() == email.trim().toLowerCase()) {
      showVToast(context, "You can't add yourself as the freelancer");
      return null;
    }
    try {
      final profile = await ref.read(authServiceProvider).lookupByEmail(email);
      log(profile.toString());
      if (profile == null) {
        showVToast(context,
            'No Veritas account found for $email — ask them to sign up first.');
        return null;
      }
      return profile;
    } catch (_) {
      showVToast(
          context, "Couldn't verify that email right now. Please try again.");
      return null;
    }
  }

  void openFreelancerPicker() {
    final invCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        bool checking = false;
        return Container(
          decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.fromLTRB(
              20, 10, 20, 28 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                            color: const Color(0xFFD8D5B8),
                            borderRadius: BorderRadius.circular(3)))),
                const SizedBox(height: 14),
                const Text('Choose a freelancer',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText)),
                const SizedBox(height: 4),
                const Text(
                    "Pick from people you've worked with, or invite by email.",
                    style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SingleChildScrollView(
                    child: Column(
                        children: _kDirectory.map((f) {
                      final sel = _freelancer?.tag == f.tag;
                      return GestureDetector(
                        onTap: checking
                            ? null
                            : () async {
                                ss(() => checking = true);
                                final profile =
                                    await _validateFreelancerEmail(f.email);
                                ss(() => checking = false);
                                if (profile == null) return;
                                setState(() => _freelancer = _FreelancerEntry(
                                      tag: f.tag,
                                      handle: f.handle,
                                      name: profile.fullName,
                                      email: f.email,
                                      avBg: f.avBg,
                                      avFg: f.avFg,
                                      rating: f.rating,
                                      verified: f.verified,
                                      skill: f.skill,
                                    ));
                                if (ctx.mounted) Navigator.of(ctx).pop();
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: sel ? AppColors.dark : AppColors.border,
                                width: sel ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            _Avatar(
                                initials: f.initials,
                                bg: _hex(f.avBg),
                                fg: _hex(f.avFg),
                                size: 40,
                                radius: 12),
                            const SizedBox(width: 11),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Text(f.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkText)),
                                    if (f.verified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF0EA868), size: 14)
                                    ],
                                  ]),
                                  Text(
                                      '${f.handle}  ·  ★ ${f.rating}  ·  ${f.skill}',
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.subText),
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            if (sel)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                    color: AppColors.dark,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.check,
                                    color: AppColors.yellow, size: 12),
                              ),
                          ]),
                        ),
                      );
                    }).toList()),
                  ),
                ),
                const SizedBox(height: 10),
                // Only email works here — the backend requires the freelancer to
                // already have a Veritas account found by email; there's no
                // pending-invite-by-tag concept.
                const Text('Or add by email',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subText2)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: invCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'name@email.com'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: checking
                        ? null
                        : () async {
                            final q = invCtrl.text.trim().toLowerCase();
                            if (q.isEmpty) return;
                            final isEmail = q.contains('@') && q.contains('.');
                            if (!isEmail) {
                              showVToast(
                                  context, 'Enter a valid email address');
                              return;
                            }
                            ss(() => checking = true);
                            final profile = await _validateFreelancerEmail(q);
                            ss(() => checking = false);
                            if (profile == null) return;
                            setState(() => _freelancer = _FreelancerEntry(
                                  tag: '',
                                  handle: q,
                                  name: profile.fullName,
                                  email: q,
                                  avBg: '#EDEBD8',
                                  avFg: '#79775F',
                                  verified: false,
                                  skill: '',
                                ));
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 13),
                      decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(13)),
                      child: checking
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.darkText),
                            )
                          : const Text('Invite',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText)),
                    ),
                  ),
                ]),
              ]),
        );
      }),
    );
  }

  // ─── Milestone editor ─────────────────────────────────────────────────────
  void openMilestoneEditor([_MS? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final dueCtrl = TextEditingController(text: existing?.due ?? '');
    final amtCtrl = TextEditingController(
        text: (existing != null && existing.amt > 0)
            ? existing.amt.toStringAsFixed(0)
            : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, ss) {
          final amtVal = double.tryParse(amtCtrl.text) ?? 0;
          final canSave = titleCtrl.text.trim().isNotEmpty && amtVal > 0;
          return Container(
            decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0xFFD8D5B8),
                          borderRadius: BorderRadius.circular(3)))),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(existing == null ? 'Add milestone' : 'Edit milestone',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText)),
                if (existing != null && _milestones.length > 1)
                  GestureDetector(
                    onTap: () {
                      setState(() => _milestones.remove(existing));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Remove',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redDark)),
                  ),
              ]),
              const SizedBox(height: 16),
              Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Milestone name',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subText2))),
              const SizedBox(height: 8),
              TextField(
                controller: titleCtrl,
                onChanged: (_) => ss(() {}),
                decoration:
                    const InputDecoration(hintText: 'e.g. Concept & moodboard'),
              ),
              const SizedBox(height: 13),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Timeline',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.subText2)),
                      const SizedBox(height: 8),
                      TextField(
                          controller: dueCtrl,
                          decoration:
                              const InputDecoration(hintText: 'Due in 7 days')),
                    ])),
                const SizedBox(width: 11),
                SizedBox(
                    width: 128,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.subText2)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amtCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => ss(() {}),
                            decoration: const InputDecoration(
                                prefixText: '\$ ', hintText: '0'),
                          ),
                        ])),
              ]),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: canSave
                    ? () {
                        final title = titleCtrl.text.trim();
                        final amt = double.tryParse(amtCtrl.text) ?? 0;
                        setState(() {
                          if (existing == null) {
                            _milestones.add(_MS(
                                id: 'cm${DateTime.now().millisecondsSinceEpoch}',
                                title: title,
                                due: dueCtrl.text.trim(),
                                amt: amt));
                          } else {
                            existing.title = title;
                            existing.due = dueCtrl.text.trim();
                            existing.amt = amt;
                          }
                        });
                        Navigator.of(ctx).pop();
                      }
                    : null,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: canSave ? AppColors.dark : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    existing == null ? 'Add milestone' : 'Save changes',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: canSave ? Colors.white : AppColors.subText),
                  ),
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }

  // ─── Fund ─────────────────────────────────────────────────────────────────
  Future<void> requestFund() async {
    final f = _freelancer!;
    final total = _total;
    final firstName = f.name.split(' ').first;

    final ok = await showVConfirm(
      context,
      title: 'Fund ${formatUSD(total)} into escrow?',
      body:
          'This locks ${formatUSD(total)} across ${_milestones.length} milestones from your wallet balance. $firstName can\'t access it until you release each one.',
      confirmLabel: 'Fund escrow',
    );
    if (ok != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      // Dollar amounts convert to percentages of the total — the backend
      // splits kobo by percentage, not by raw amount.
      final milestoneInputs = _milestones
          .map((m) =>
              MilestoneInput(title: m.title, percentage: (m.amt / total) * 100))
          .toList();
      final amountKobo = (total * fxRate * 100).round();

      await ref.read(escrowServiceProvider).createEscrow(
            title: _projectCtrl.text.trim(),
            freelancerEmail: f.email,
            amountKobo: amountKobo,
            // Not collected in this flow yet — defaults to 30 days out.
            deadlineAt: DateTime.now().add(const Duration(days: 30)),
            milestones: milestoneInputs,
          );

      await refreshContracts(ref);
      try {
        await refreshWalletBalance(ref);
      } catch (_) {
        // Non-fatal — balance just stays stale until the next refresh.
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showVToast(context, 'Escrow funded — $firstName has been notified!');
    } on ApiException catch (e) {
      if (mounted) showVToast(context, e.message);
    } catch (_) {
      if (mounted)
        showVToast(context, 'Could not create the escrow. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Step widgets ─────────────────────────────────────────────────────────────

class _StepDetails extends StatefulWidget {
  final _CreateEscrowScreenState state;
  const _StepDetails({super.key, required this.state});

  @override
  State<_StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends State<_StepDetails> {
  bool _catAdding = false;
  final _catCtrl = TextEditingController();

  @override
  void dispose() {
    _catCtrl.dispose();
    super.dispose();
  }

  _CreateEscrowScreenState get s => widget.state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Who's it for & what's the work?",
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
                letterSpacing: -0.4)),
        const SizedBox(height: 4),
        const Text("Name the project and choose who you're hiring.",
            style: TextStyle(fontSize: 13, color: AppColors.subText)),
        const SizedBox(height: 20),

        // Project title
        const Text('Project title',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.subText2)),
        const SizedBox(height: 9),
        TextField(
          controller: s._projectCtrl,
          onChanged: (_) => s.setState(() {}),
          decoration:
              const InputDecoration(hintText: 'e.g. Brand identity & logo'),
        ),

        // Freelancer selector
        const SizedBox(height: 18),
        const Text('Freelancer',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.subText2)),
        const SizedBox(height: 9),
        GestureDetector(
          onTap: s.openFreelancerPicker,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color:
                      s._freelancer != null ? AppColors.dark : AppColors.border,
                  width: s._freelancer != null ? 1.5 : 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              _Avatar(
                initials: s._freelancer?.initials ?? '?',
                bg: s._freelancer != null
                    ? s._hex(s._freelancer!.avBg)
                    : const Color(0xFFEDEBD8),
                fg: s._freelancer != null
                    ? s._hex(s._freelancer!.avFg)
                    : AppColors.subText2,
                size: 40,
                radius: 12,
              ),
              const SizedBox(width: 11),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      s._freelancer?.name ?? 'Select a freelancer',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: s._freelancer != null
                              ? AppColors.darkText
                              : AppColors.subText),
                    ),
                    if (s._freelancer != null)
                      Text(s._freelancer!.handle,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.subText)),
                  ])),
              if (s._freelancer != null)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                      color: Color(0xFF0EA868), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 13),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.subText, size: 20),
            ]),
          ),
        ),

        // Category
        const SizedBox(height: 18),
        const Text('Category',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.subText2)),
        const SizedBox(height: 9),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...s._allCats.map((cat) {
                final sel = cat == s._category;
                return GestureDetector(
                  onTap: () => s.setState(() => s._category = cat),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.dark : Colors.white,
                      border: Border.all(
                          color: sel ? AppColors.dark : AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color:
                                sel ? AppColors.yellow : AppColors.darkText)),
                  ),
                );
              }),
              if (_catAdding)
                Container(
                  padding: const EdgeInsets.fromLTRB(13, 3, 4, 3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.dark, width: 1.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      width: 118,
                      child: TextField(
                        controller: _catCtrl,
                        autofocus: true,
                        onSubmitted: _saveCat,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText),
                        decoration: const InputDecoration(
                            hintText: 'Type a category',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _saveCat(_catCtrl.text),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                            color: AppColors.yellow, shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            size: 14, color: AppColors.darkText),
                      ),
                    ),
                  ]),
                )
              else
                GestureDetector(
                  onTap: () => setState(() => _catAdding = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFC9C6A6),
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add,
                          size: 13, color: AppColors.subText2),
                      const SizedBox(width: 5),
                      const Text('Other',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.subText2)),
                    ]),
                  ),
                ),
            ]),

        const SizedBox(height: 32),
        _ContBtn(enabled: s._step1Valid, onTap: s._next),
      ]),
    );
  }

  void _saveCat(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      setState(() {
        _catAdding = false;
        _catCtrl.clear();
      });
      return;
    }
    s.setState(() {
      final exist = s._allCats.firstWhere(
          (c) => c.toLowerCase() == name.toLowerCase(),
          orElse: () => '');
      if (exist.isNotEmpty) {
        s._category = exist;
      } else {
        s._customCats.add(name);
        s._category = name;
      }
    });
    setState(() {
      _catAdding = false;
      _catCtrl.clear();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepMilestones extends StatelessWidget {
  final _CreateEscrowScreenState state;
  const _StepMilestones({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final total = s._total;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Set the budget & milestones',
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
                letterSpacing: -0.4)),
        const SizedBox(height: 4),
        const Text(
            "Break the work into stages. You release each one as it's approved.",
            style: TextStyle(fontSize: 13, color: AppColors.subText)),
        const SizedBox(height: 18),

        // Total budget card
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
              color: AppColors.dark, borderRadius: BorderRadius.circular(18)),
          child: Stack(children: [
            Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 16)),
                )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(formatUSD(total),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1)),
                const SizedBox(height: 5),
                Text('≈ ${formatNGN(total)}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.yellow)),
              ]),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFF3FCF6E), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text('USDC',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.yellow)),
                ]),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Milestones (${s._milestones.length})',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subText2)),
          const Text('Total auto-summed',
              style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
        ]),
        const SizedBox(height: 9),

        ...s._milestones.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GestureDetector(
                onTap: () => s.openMilestoneEditor(e.value),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    _NumBadge(e.key + 1),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(e.value.title,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText),
                              overflow: TextOverflow.ellipsis),
                          if (e.value.due.isNotEmpty)
                            Text(e.value.due,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.subText)),
                        ])),
                    Text(e.value.amt > 0 ? formatUSD(e.value.amt) : '—',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFFC9C6A6), size: 17),
                  ]),
                ),
              ),
            )),

        GestureDetector(
          onTap: () => s.openMilestoneEditor(),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC9C6A6)),
                borderRadius: BorderRadius.circular(14)),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.subText2, size: 16),
                  SizedBox(width: 7),
                  Text('Add milestone',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.subText2)),
                ]),
          ),
        ),

        const SizedBox(height: 32),
        _ContBtn(enabled: s._step2Valid, onTap: s._next),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  final _CreateEscrowScreenState state;
  const _StepReview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final f = s._freelancer!;
    final total = s._total;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Review & fund',
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
                letterSpacing: -0.4)),
        const SizedBox(height: 4),
        const Text('Confirm the details — then lock the budget into escrow.',
            style: TextStyle(fontSize: 13, color: AppColors.subText)),
        const SizedBox(height: 18),

        // Summary card
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: [
            _RRow('Project', s._projectCtrl.text),
            // Freelancer row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Freelancer',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.subText2)),
                    Row(children: [
                      _Avatar(
                          initials: f.initials,
                          bg: s._hex(f.avBg),
                          fg: s._hex(f.avFg),
                          size: 24,
                          radius: 8),
                      const SizedBox(width: 8),
                      Text(f.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText)),
                    ]),
                  ]),
            ),
            const Divider(height: 1, color: Color(0xFFF1EFD6)),
            _RRow('Category', s._category),
            _RRow('Milestones', '${s._milestones.length} stages', isLast: true),
          ]),
        ),

        const SizedBox(height: 11),

        // Milestone list
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
              children: s._milestones.asMap().entries.map((e) {
            final isLast = e.key == s._milestones.length - 1;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(children: [
                  _NumBadge(e.key + 1, small: true),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(e.value.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText),
                            overflow: TextOverflow.ellipsis),
                        if (e.value.due.isNotEmpty)
                          Text(e.value.due,
                              style: const TextStyle(
                                  fontSize: 10.5, color: AppColors.subText)),
                      ])),
                  Text(formatUSD(e.value.amt),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText)),
                ]),
              ),
              if (!isLast) const Divider(height: 1, color: Color(0xFFF1EFD6)),
            ]);
          }).toList()),
        ),

        const SizedBox(height: 11),

        // Total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
              color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total to fund',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(formatUSD(total),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.yellow,
                    letterSpacing: -0.4)),
          ]),
        ),

        const SizedBox(height: 11),

        // Escrow note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF6D2),
              borderRadius: BorderRadius.circular(16)),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: Color(0xFFC9A800), size: 20),
                SizedBox(width: 11),
                Expanded(
                    child: Text(
                  'Protected by Veritas escrow. Funds lock the moment you pay and only release when you approve each milestone.',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF5C5320), height: 1.5),
                )),
              ]),
        ),

        const SizedBox(height: 20),

        // Fund button
        GestureDetector(
          onTap: s._submitting ? null : s.requestFund,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
                color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, color: AppColors.yellow, size: 17),
              const SizedBox(width: 9),
              Text(
                s._submitting
                    ? 'Funding…'
                    : 'Fund escrow · ${formatUSD(total)}',
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.yellow),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Tiny shared widgets ──────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  final Color color;
  const _Bar(this.color);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      );
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color bg, fg;
  final double size, radius;
  const _Avatar(
      {required this.initials,
      required this.bg,
      required this.fg,
      required this.size,
      required this.radius});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(radius)),
        alignment: Alignment.center,
        child: Text(initials,
            style: TextStyle(
                fontSize: size * 0.33, fontWeight: FontWeight.w800, color: fg)),
      );
}

class _NumBadge extends StatelessWidget {
  final int num;
  final bool small;
  const _NumBadge(this.num, {this.small = false});
  @override
  Widget build(BuildContext context) {
    final sz = small ? 22.0 : 27.0;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
          color: const Color(0xFFFFF1CC),
          borderRadius: BorderRadius.circular(small ? 7 : 8)),
      alignment: Alignment.center,
      child: Text('$num',
          style: TextStyle(
              fontSize: small ? 11.0 : 12.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF9A7B00))),
    );
  }
}

class _ContBtn extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ContBtn({required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: enabled ? AppColors.dark : AppColors.lightBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Continue',
              style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: enabled ? Colors.white : AppColors.subText)),
        ),
      );
}

class _RRow extends StatelessWidget {
  final String label, value;
  final bool isLast;
  const _RRow(this.label, this.value, {this.isLast = false});
  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.subText2)),
            Flexible(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText),
                    textAlign: TextAlign.right,
                    maxLines: 2)),
          ]),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1EFD6)),
      ]);
}
