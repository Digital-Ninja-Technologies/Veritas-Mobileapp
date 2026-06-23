import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final _topics = ['Track my withdrawal', 'Dispute status', 'KYC verification', 'Can\'t log in'];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    ref.read(supportMessagesProvider.notifier).addMessage(SupportMessage(
      text: text.trim(),
      isUser: true,
      time: DateTime.now(),
    ));
    setState(() => _isTyping = true);
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isTyping = false);

    final reply = _autoReply(text.trim().toLowerCase());
    ref.read(supportMessagesProvider.notifier).addMessage(SupportMessage(
      text: reply,
      isUser: false,
      time: DateTime.now(),
    ));
    _scrollToBottom();
  }

  String _autoReply(String input) {
    if (input.contains('withdraw')) return 'Withdrawals typically arrive within 2–4 business hours. If it\'s been longer than 24 hours, please share your reference number and I\'ll investigate right away.';
    if (input.contains('dispute')) return 'Dispute cases are reviewed within 48 hours. Our resolution team examines both parties\' evidence. You can track your case status on the contract detail screen.';
    if (input.contains('kyc')) return 'KYC verification usually takes 1–2 business hours after you submit your documents. Make sure the photos are clear and all corners of the document are visible.';
    if (input.contains('login') || input.contains('log in') || input.contains('password')) return 'For login issues, try resetting your password via the login screen. If you\'re still having trouble, I can escalate to our security team.';
    return 'Thanks for reaching out! I\'m Tomi, your Veritas support agent. I\'ve noted your message and will help you as quickly as possible. Can you share more details?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(supportMessagesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const VBackButton(),
                  const SizedBox(width: 14),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.support_agent, color: AppColors.darkText, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tomi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkText)),
                      Row(children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        const Text('Veritas support · Online', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: messages.length <= 1 && !messages.any((m) => m.isUser)
                  ? _emptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_isTyping && i == messages.length) return _TypingBubble();
                        final m = messages[i];
                        return _MessageBubble(message: m);
                      },
                    ),
            ),
            if (!messages.any((m) => m.isUser)) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _topics.map((t) => GestureDetector(
                    onTap: () => _sendMessage(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                    ),
                  )).toList(),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _sendMessage(_msgCtrl.text),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.yellow.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.support_agent_outlined, color: AppColors.darkText, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Hi! I\'m Tomi 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText)),
          const SizedBox(height: 6),
          const Text('How can I help you today?', style: TextStyle(fontSize: 14, color: AppColors.subText2)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final fromUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.support_agent, color: AppColors.darkText, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: fromUser ? AppColors.dark : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(fromUser ? 16 : 4),
                  bottomRight: Radius.circular(fromUser ? 4 : 16),
                ),
                border: fromUser ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                message.text,
                style: TextStyle(fontSize: 14, color: fromUser ? Colors.white : AppColors.darkText, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.support_agent, color: AppColors.darkText, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _Dot(delay: 0),
              const SizedBox(width: 4),
              _Dot(delay: 200),
              const SizedBox(width: 4),
              _Dot(delay: 400),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: AppColors.subText.withOpacity(0.3 + _anim.value * 0.7),
        shape: BoxShape.circle,
      ),
    ),
  );
}
