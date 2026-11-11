import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/repositories/assistant_repository.dart';
import '../../shared/widgets/discreet_camouflage_view.dart';
import '../../shared/widgets/language_selector_sheet.dart';
import '../../shared/widgets/voice_selector_sheet.dart';

class HerHelpAssistantScreen extends ConsumerStatefulWidget {
  const HerHelpAssistantScreen({super.key});

  @override
  ConsumerState<HerHelpAssistantScreen> createState() => _HerHelpAssistantScreenState();
}

class _HerHelpAssistantScreenState extends ConsumerState<HerHelpAssistantScreen> {
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
    if (mounted) {
      setState(() => _messages = list);
    }
  }

  Future<void> _ask(String text) async {
    if (text.trim().isEmpty) return;
    final q = text.trim();
    _controller.clear();
    setState(() => _isLoading = true);

    await _repo.askAssistant(q);
    await _loadConversation();

    if (mounted) {
      setState(() => _isLoading = false);
    }

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
    ref.read(ttsServiceProvider).stop();
    _repo.clearSession();
    _loadConversation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('sessionErased')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showGeminiConfigSheet() {
    final keyController = TextEditingController();
    final hasKey = _repo.hasGeminiApiKey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender,
                        borderRadius: AppRadius.mdBorder,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Gemini AI Engine',
                            style: AppTypography.headlineSM(),
                          ),
                          Text(
                            hasKey
                                ? '✨ Live Gemini 1.5 Flash Connected'
                                : 'Free AI Studio Key (or Local Knowledge Mode)',
                            style: AppTypography.labelSM(
                              color: hasKey ? AppColors.success : AppColors.neutralMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'HerHelp uses Google Gemini 1.5 Flash for confidential, compassionate menstrual health guidance. Enter your free API key from Google AI Studio to unlock live generative responses.',
                  style: AppTypography.bodySM(color: AppColors.neutralMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: keyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key',
                    hintText: hasKey ? '••••••••••••••••••••' : 'AIzaSy...',
                    prefixIcon: const Icon(Icons.key, color: AppColors.primaryContainer),
                    border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                    helperText: 'Stored encrypted on your local device. 100% free.',
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final key = keyController.text.trim();
                          if (key.isNotEmpty) {
                            await _repo.setGeminiApiKey(key);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✨ Gemini API Key saved successfully!'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save Key'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

    final currentLang = ref.watch(appLocaleProvider);
    final tts = ref.watch(ttsServiceProvider);
    final isGeminiActive = _repo.hasGeminiApiKey;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            tts.stop();
            context.pop();
          },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(context.tr('herHelpAssistant'), style: AppTypography.labelLG()),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isGeminiActive
                              ? AppColors.primaryContainer.withValues(alpha: 0.15)
                              : AppColors.softLavender,
                          borderRadius: AppRadius.fullBorder,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 10, color: AppColors.primaryContainer),
                            const SizedBox(width: 2),
                            Text(
                              isGeminiActive ? 'Gemini 1.5' : 'Gemini AI',
                              style: AppTypography.labelSM(color: AppColors.primaryContainer)
                                  .copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    context.tr('herHelpSubtitle'),
                    style: AppTypography.labelSM(color: AppColors.primaryContainer),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Gemini API Key Config
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.primaryContainer),
            tooltip: 'Gemini AI Configuration',
            onPressed: _showGeminiConfigSheet,
          ),
          // Voice Selection from FreeAPI
          IconButton(
            icon: const Icon(Icons.record_voice_over_outlined),
            tooltip: context.tr('voiceSettings'),
            onPressed: () {
              VoiceSelectorSheet.show(context, currentLanguageCode: currentLang.code);
            },
          ),
          // Language Switcher
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: context.tr('selectLanguage'),
            onPressed: () {
              LanguageSelectorSheet.show(
                context,
                currentLocaleCode: currentLang.code,
                onSelect: (lang) {
                  ref.read(appLocaleProvider.notifier).setLanguage(lang);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            tooltip: context.tr('camouflageMode'),
            onPressed: () => setState(() => _isCamouflageActive = true),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: context.tr('clearSession'),
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
                        context.tr('zeroKnowledgeMode'),
                        style: AppTypography.labelSM(color: AppColors.neutralDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Conversation List
              Expanded(
                child: ListenableBuilder(
                  listenable: tts,
                  builder: (context, _) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg.isUser;
                        final isThisSpeaking =
                            tts.isPlaying && tts.currentlySpeakingText == msg.content;
                        final isThisLoading =
                            tts.isLoading && tts.currentlySpeakingText == msg.content;

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
                                  maxWidth: MediaQuery.of(context).size.width * 0.85,
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
                                      : Border.all(
                                          color: isThisSpeaking
                                              ? AppColors.primaryContainer
                                              : AppColors.borderSubtle,
                                        ),
                                  boxShadow: AppElevation.level1,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                msg.isLiveAi ? Icons.auto_awesome : Icons.favorite,
                                                size: 14,
                                                color: msg.isLiveAi
                                                    ? AppColors.primaryContainer
                                                    : AppColors.coralPink,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                msg.isLiveAi
                                                    ? '✨ Gemini 1.5 Flash'
                                                    : 'HerHelp Companion',
                                                style: AppTypography.labelSM(
                                                  color: AppColors.primaryContainer,
                                                ).copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          // Text to Speech Read Aloud Button
                                          InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () {
                                              if (isThisSpeaking) {
                                                tts.stop();
                                              } else {
                                                tts.speak(
                                                  msg.content,
                                                  languageCode: currentLang.code,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isThisSpeaking
                                                    ? AppColors.primaryContainer
                                                    : AppColors.secondaryContainer,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (isThisLoading)
                                                    const SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.primaryContainer,
                                                      ),
                                                    )
                                                  else
                                                    Icon(
                                                      isThisSpeaking
                                                          ? Icons.stop
                                                          : Icons.volume_up,
                                                      size: 14,
                                                      color: isThisSpeaking
                                                          ? Colors.white
                                                          : AppColors.primaryContainer,
                                                    ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isThisLoading
                                                        ? 'TTS...'
                                                        : isThisSpeaking
                                                            ? context.tr('stopAudio')
                                                            : context.tr('listenAudio'),
                                                    style: AppTypography.labelSM(
                                                      color: isThisSpeaking
                                                          ? Colors.white
                                                          : AppColors.primaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                    Text(
                                      context.tr(msg.content),
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
                                    label: Text(context.tr(chipText),
                                        style: AppTypography.labelSM()),
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
                    );
                  },
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HerHelp (Gemini) is thinking...',
                        style: AppTypography.labelSM(color: AppColors.primaryContainer),
                      ),
                    ],
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
                      tooltip: 'Voice Prompt',
                      onPressed: () {
                        _ask('How can I find a safe pad distribution hub near me?');
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: context.tr('askHerHelp'),
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
