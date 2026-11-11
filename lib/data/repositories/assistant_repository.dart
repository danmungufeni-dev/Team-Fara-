class AssistantMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionChips;

  const AssistantMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.actionChips,
  });
}

abstract class IAssistantRepository {
  Future<List<AssistantMessage>> getConversation();
  Future<AssistantMessage> askAssistant(String question);
  Future<void> clearSession();
}

class AssistantRepository implements IAssistantRepository {
  final List<AssistantMessage> _messages = [
    AssistantMessage(
      id: 'init_1',
      content: 'Hello, I am HerHelp, your safe and confidential PadCare companion. Everything discussed in this session is completely private, unlogged, and wiped when you exit.\n\nHow can I support your menstrual health and dignity today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      actionChips: const [
        'Request free pads discreetly',
        'Severe cramps relief remedies',
        'Find safe distribution hub',
        'How does anonymous pickup work?',
      ],
    ),
  ];

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

    // Contextual dignity-first response
    String reply = '';
    final q = question.toLowerCase();

    if (q.contains('pad') || q.contains('request') || q.contains('free')) {
      reply = 'You can reserve free sanitary pads completely discreetly. No ID, phone number or name will be requested at the center. Once you tap "Get Code", you receive a 6-character voucher (e.g. PAD-749) sealed in an opaque kraft bag.';
    } else if (q.contains('cramp') || q.contains('pain') || q.contains('relief')) {
      reply = 'For menstrual cramp discomfort, helpful non-medical relief includes:\n• Applying gentle warmth (warm water compress or bottle) to your lower abdomen\n• Staying hydrated with warm water or herbal tea\n• Gentle walking and light stretching\n\n⚠️ Note: If your pain is unusually severe, sudden, or accompanied by dizziness or heavy bleeding, please speak with a registered healthcare provider or visit your nearest primary health center.';
    } else if (q.contains('hub') || q.contains('find') || q.contains('where')) {
      reply = 'There are multiple verified safe collection hubs near you in Kampala, including Kisenyi Health Center IV (850m away) and WoMena Community Sanctuary (1.4km). Both have verified female caretakers on duty and private counters.';
    } else if (q.contains('anonymous') || q.contains('pickup') || q.contains('work')) {
      reply = 'Anonymous pickup is simple:\n1. Choose a nearby hub on the map or home screen\n2. Tap "Reserve Discreet Pack"\n3. Note your confidential 6-digit code (e.g. PAD-749)\n4. Walk to the dispensary counter and whisper or show the code\n5. Collect your sealed, unlabelled kraft bag.';
    } else {
      reply = 'Thank you for reaching out. PadCare is here to support you with free menstrual products, private guidance, and verified safe spaces across Uganda. If you have medical concerns, please consult a qualified healthcare worker.';
    }

    final botMsg = AssistantMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      content: reply,
      isUser: false,
      timestamp: DateTime.now(),
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
        content: 'New zero-trace session started. All previous messages were wiped from memory.',
        isUser: false,
        timestamp: DateTime.now(),
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
