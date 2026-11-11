import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/core/services/gemini_service.dart';
import 'package:padcare/data/repositories/assistant_repository.dart';

void main() {
  late GeminiService geminiService;
  late AssistantRepository assistantRepository;

  setUp(() {
    geminiService = GeminiService.instance;
    assistantRepository = AssistantRepository();
  });

  group('GeminiService & HerHelp AI Assistant Tests', () {
    test('Identifies API key configuration correctly', () {
      // Default placeholder is not configured
      expect(geminiService.hasApiKey, isFalse);
    });

    test('Answers menstrual cramp relief questions with evidence-based guidance', () async {
      final res = await geminiService.askHerHelp(
        question: 'What can I do for severe period cramps?',
      );

      expect(res.text.toLowerCase(), contains('warm'));
      expect(res.text.toLowerCase(), anyOf([contains('hydrate'), contains('water')]));
      expect(res.suggestedChips, isNotEmpty);
    });

    test('Explains anonymous voucher pickup protocol clearly', () async {
      final res = await geminiService.askHerHelp(
        question: 'How do I get free pads anonymously?',
      );

      expect(res.text, contains('PAD-'));
      expect(res.text.toLowerCase(), contains('kraft'));
      expect(res.suggestedChips, contains('How does anonymous pickup work?'));
    });

    test('AssistantRepository appends messages and wipes session on demand', () async {
      final initial = await assistantRepository.getConversation();
      expect(initial.length, 1);

      await assistantRepository.askAssistant('Where is the nearest hub?');
      final updated = await assistantRepository.getConversation();
      expect(updated.length, 3); // Initial + user + bot

      await assistantRepository.clearSession();
      final wiped = await assistantRepository.getConversation();
      expect(wiped.length, 1);
      expect(wiped.first.content, contains('zero-trace'));
    });
  });
}
