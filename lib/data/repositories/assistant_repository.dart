import '../../core/services/gemini_service.dart';

class AssistantMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionChips;
  final bool isLiveAi;

  const AssistantMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.actionChips,
    this.isLiveAi = false,
  });
}

abstract class IAssistantRepository {
  Future<List<AssistantMessage>> getConversation();
  Future<AssistantMessage> askAssistant(String question);
  Future<void> clearSession();
  bool get hasGeminiApiKey;
  Future<void> setGeminiApiKey(String apiKey);
}

class AssistantRepository implements IAssistantRepository {
  final GeminiService _gemini = GeminiService.instance;

  final List<AssistantMessage> _messages = [
    AssistantMessage(
      id: 'init_1',
      content:
          'Hello, I am HerHelp, your safe and confidential PadCare companion powered by Google Gemini. Everything discussed here is completely private, unlogged, and wiped when you exit.\n\nHow can I support your menstrual health and dignity today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isLiveAi: false,
      actionChips: const [
        'Request free pads discreetly',
        'Severe cramps relief remedies',
        'Find safe distribution hub',
        'How does anonymous pickup work?',
      ],
    ),
  ];

  @override
  bool get hasGeminiApiKey => _gemini.hasApiKey;

  @override
  Future<void> setGeminiApiKey(String apiKey) async {
    await _gemini.setApiKey(apiKey);
  }

  @override
  Future<List<AssistantMessage>> getConversation() async {
    return List.unmodifiable(_messages);
  }

  @override
  Future<AssistantMessage> askAssistant(String question) async {
    final userMsg = AssistantMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: question,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    // Build context history for multi-turn Gemini conversation
    final history = _messages
        .where((m) => m.id != userMsg.id && !m.id.startsWith('init'))
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.content,
            })
        .toList();

    final geminiRes = await _gemini.askHerHelp(
      question: question,
      conversationHistory: history,
    );

    final botMsg = AssistantMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      content: geminiRes.text,
      isUser: false,
      timestamp: DateTime.now(),
      actionChips: geminiRes.suggestedChips,
      isLiveAi: geminiRes.isLiveAi,
    );
    _messages.add(botMsg);
    return botMsg;
  }

  @override
  Future<void> clearSession() async {
    _messages.clear();
    _messages.add(
      AssistantMessage(
        id: 'init_${DateTime.now().millisecondsSinceEpoch}',
        content:
            'New zero-trace session started. All previous messages were wiped from memory.',
        isUser: false,
        timestamp: DateTime.now(),
        isLiveAi: false,
        actionChips: const [
          'Request free pads discreetly',
          'Severe cramps relief remedies',
          'Find safe distribution hub',
          'How does anonymous pickup work?',
        ],
      ),
    );
  }
}
