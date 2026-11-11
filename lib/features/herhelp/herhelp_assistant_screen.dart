import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/repositories/assistant_repository.dart';
import '../../shared/widgets/discreet_camouflage_view.dart';

class HerHelpAssistantScreen extends StatefulWidget {
  const HerHelpAssistantScreen({super.key});

  @override
  State<HerHelpAssistantScreen> createState() => _HerHelpAssistantScreenState();
}

class _HerHelpAssistantScreenState extends State<HerHelpAssistantScreen> {
  final AssistantRepository _repo = AssistantRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AssistantMessage> _messages = [];
  bool _isLoading = false;
  bool _isCamouflageActive = false;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    final list = await _repo.getConversation();
    setState(() => _messages = list);
  }

  Future<void> _ask(String text) async {
    if (text.trim().isEmpty) return;
    final q = text.trim();
    _controller.clear();
    setState(() => _isLoading = true);

    await _repo.askAssistant(q);
    await _loadConversation();

    setState(() => _isLoading = false);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearSession() {
    _repo.clearSession();
    _loadConversation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session erased. Zero-Trace privacy maintained.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCamouflageActive) {
      return DiscreetCamouflageView(
        onExitCamouflage: () => setState(() => _isCamouflageActive = false),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  AssetPaths.chatbotIcon,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.favorite,
                    color: AppColors.coralPink,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HerHelp Assistant', style: AppTypography.labelLG()),
                Text(
                  'End-to-End Private & Unlogged',
                  style: AppTypography.labelSM(color: AppColors.primaryContainer),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            tooltip: 'Camouflage Screen',
            onPressed: () => setState(() => _isCamouflageActive = true),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Session',
            onPressed: _clearSession,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Zero-Knowledge Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield, size: 16, color: AppColors.primaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zero-Knowledge Mode Active • No conversations are logged or saved to server.',
                        style: AppTypography.labelSM(color: AppColors.neutralDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Conversation List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg.isUser;

                    return Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:
                              isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.82,
                            ),
                            padding: const EdgeInsets.all(14),
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
                              border: isUser
                                  ? null
                                  : Border.all(color: AppColors.borderSubtle),
                              boxShadow: AppElevation.level1,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite,
                                          size: 14, color: AppColors.coralPink),
                                      const SizedBox(width: 4),
                                      Text(
                                        'HerHelp Care Companion',
                                        style: AppTypography.labelSM(
                                            color: AppColors.primaryContainer),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  msg.content,
                                  style: AppTypography.bodyMD(
                                    color: isUser ? Colors.white : AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action chips if attached
                        if (msg.actionChips != null && msg.actionChips!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: msg.actionChips!.map((chipText) {
                              return ActionChip(
                                label: Text(chipText, style: AppTypography.labelSM()),
                                backgroundColor: AppColors.softLavender,
                                side: BorderSide.none,
                                onPressed: () => _ask(chipText),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    color: AppColors.primaryContainer,
                    backgroundColor: AppColors.softLavender,
                  ),
                ),

              // Composer Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(top: BorderSide(color: AppColors.borderSubtle)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic, color: AppColors.primaryContainer),
                      onPressed: () {
                        _ask('How can I find a safe pad distribution hub near me?');
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Ask HerHelp confidential health questions...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _ask,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primaryContainer),
                      onPressed: () => _ask(_controller.text),
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
