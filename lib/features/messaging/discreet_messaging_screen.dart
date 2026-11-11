import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/discreet_message.dart';
import '../../data/services/mock_backend_store.dart';

class DiscreetMessagingScreen extends StatefulWidget {
  const DiscreetMessagingScreen({super.key});

  @override
  State<DiscreetMessagingScreen> createState() =>
      _DiscreetMessagingScreenState();
}

class _DiscreetMessagingScreenState extends State<DiscreetMessagingScreen> {
  final MockBackendStore _store = MockBackendStore();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickReplies = [
    "I'm outside Counter 3",
    "Is female nurse present?",
    "Can I pick up tomorrow?",
    "Code PAD-749",
  ];

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final newMsg = DiscreetMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      voucherCode: 'PAD-749',
      senderId: _store.currentUser.id,
      senderName: _store.currentUser.pseudonym,
      message: text,
      timestamp: DateTime.now(),
      isSeeker: true,
      isDelivered: true,
      isRead: true,
    );

    setState(() {
      _store.messages.add(newMsg);
      if (presetText == null) {
        _textController.clear();
      }
    });

    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulated dispensary reply after short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final reply = DiscreetMessage(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          voucherCode: 'PAD-749',
          senderId: 'hub_kisenyi',
          senderName: 'Nurse Harriet (Kisenyi)',
          message: 'Received. Counter 3 is open and clear right now. Matron Grace has your opaque kraft parcel ready.',
          timestamp: DateTime.now(),
          isSeeker: false,
          isDelivered: true,
          isRead: true,
        );
        setState(() {
          _store.messages.add(reply);
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _store.messages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Kisenyi Health Center IV', style: AppTypography.labelLG()),
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 16, color: AppColors.success),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.shield, size: 12, color: AppColors.primaryContainer),
                const SizedBox(width: 4),
                Text(
                  'End-to-End Anonymous Chat • #PAD-749',
                  style: AppTypography.labelSM(color: AppColors.primaryContainer),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat messages self-destruct upon pack collection.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Pinned Active Voucher Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.cardBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: AppElevation.level1,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender,
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: const Icon(Icons.inventory_2, color: AppColors.primaryContainer, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Voucher #PAD-749', style: AppTypography.labelMD(color: AppColors.neutralDark)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCF8EC),
                                  borderRadius: AppRadius.fullBorder,
                                ),
                                child: Text('Counter 3', style: AppTypography.labelSM(color: AppColors.success)),
                              ),
                            ],
                          ),
                          Text('Ready for Collection • Expires in 38m', style: AppTypography.bodySM(color: AppColors.coralPink)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push('/map'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: AppRadius.fullBorder,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.near_me, size: 14, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text('Map', style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Thread List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.isSeeker;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: isUser ? null : Border.all(color: AppColors.borderSubtle),
                          boxShadow: AppElevation.level1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Text(
                                msg.senderName,
                                style: AppTypography.labelSM(color: AppColors.primaryContainer).copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              msg.message,
                              style: AppTypography.bodyMD(
                                color: isUser ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: AppTypography.labelSM(
                                    color: isUser ? Colors.white70 : AppColors.neutralMuted,
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.done_all, size: 14, color: Colors.white70),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick replies horizontal chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickReplies.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final reply = _quickReplies[index];
                    return ActionChip(
                      label: Text(reply, style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                      backgroundColor: AppColors.surfaceContainerLowest,
                      side: const BorderSide(color: AppColors.borderSubtle),
                      onPressed: () => _sendMessage(reply),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Message Composer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 18, color: AppColors.neutralMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Type confidential message...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primaryContainer),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
