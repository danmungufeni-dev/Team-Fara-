import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService.instance;
});

class GeminiResponse {
  final String text;
  final List<String> suggestedChips;
  final bool isLiveAi;

  const GeminiResponse({
    required this.text,
    required this.suggestedChips,
    required this.isLiveAi,
  });
}

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  GenerativeModel? _model;
  String? _activeApiKey;

  static const String systemInstruction = '''
You are HerHelp, an empathetic, safe, confidential menstrual health and dignity companion designed for the PadCare platform.
Your mission is to support women, adolescent girls, and menstruating individuals across East Africa (Uganda, Kenya, Tanzania, Rwanda, Burundi, South Sudan, DR Congo) and globally.

Core principles:
1. Empathy & Dignity: Speak with kindness, compassion, and non-judgmental language. Menstruation is natural, healthy, and dignified.
2. Practical & Confidential Support:
   - Provide evidence-based menstrual hygiene guidance (regular pad changes, cleansing with clean water, hygienic drying of reusable pads, safe disposal).
   - Offer safe, non-medical remedies for menstrual cramps (warm compress, hydration, gentle pelvic stretches, rest).
   - Explain how PadCare anonymous voucher pickup works (free pads collected with a 6-character code like PAD-749 in an opaque kraft bag with no ID or phone required).
   - Point to local safe hubs like Kisenyi Health Center IV, WoMena Community Sanctuary, and Mulago Referral Hospital in Kampala.
3. Medical Safety: Always clarify that you are a health companion, not a replacement for a doctor. If bleeding is excessively heavy (soaking a pad in 1 hour) or pain is unbearable with fever, gently encourage visiting a local clinic.
4. Response Format: Keep responses concise, warm, bullet-pointed where helpful, and culturally respectful.
''';

  /// Check whether a Gemini API key is configured
  bool get hasApiKey {
    final key = _getEffectiveApiKey();
    return key.isNotEmpty && !key.contains('YOUR_') && key != 'PLACEHOLDER';
  }

  String _getEffectiveApiKey() {
    return _activeApiKey ??
        LocalStorage.getString(AppConstants.storageKeyGeminiApiKey) ??
        const String.fromEnvironment(AppConstants.envGeminiApiKey);
  }

  /// Configure or update Gemini API key
  Future<void> setApiKey(String key) async {
    _activeApiKey = key.trim();
    await LocalStorage.setString(AppConstants.storageKeyGeminiApiKey, _activeApiKey!);
    _initModel();
  }

  void _initModel() {
    final key = _getEffectiveApiKey();
    if (key.isNotEmpty && !key.contains('YOUR_')) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: key,
          systemInstruction: Content.system(systemInstruction),
        );
        debugPrint('✨ [GeminiService] Initialized with model gemini-1.5-flash');
      } catch (e) {
        debugPrint('⚠️ [GeminiService] Failed to initialize GenerativeModel: $e');
        _model = null;
      }
    }
  }

  /// Ask HerHelp with user prompt and previous conversation context.
  Future<GeminiResponse> askHerHelp({
    required String question,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final key = _getEffectiveApiKey();

    if (key.isNotEmpty && !key.contains('YOUR_')) {
      // 1. Try official SDK
      try {
        if (_model == null) _initModel();

        if (_model != null) {
          final historyContents = conversationHistory.map((item) {
            final isUser = item['role'] == 'user';
            return isUser
                ? Content.text(item['text'] ?? '')
                : Content.model([TextPart(item['text'] ?? '')]);
          }).toList();

          final chat = _model!.startChat(history: historyContents);
          final response = await chat.sendMessage(Content.text(question));
          final text = response.text;

          if (text != null && text.trim().isNotEmpty) {
            return GeminiResponse(
              text: text.trim(),
              suggestedChips: _generateFollowupChips(question),
              isLiveAi: true,
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ [GeminiService] SDK error, attempting direct REST fallback: $e');
        // 2. Direct REST fallback
        try {
          final restRes = await _callGeminiRest(key, question, conversationHistory);
          if (restRes != null && restRes.trim().isNotEmpty) {
            return GeminiResponse(
              text: restRes.trim(),
              suggestedChips: _generateFollowupChips(question),
              isLiveAi: true,
            );
          }
        } catch (restErr) {
          debugPrint('⚠️ [GeminiService] REST fallback error: $restErr');
        }
      }
    }

    // 3. Compassionate local fallback with clear AI status
    final fallback = _getLocalCuratedResponse(question);
    return GeminiResponse(
      text: fallback,
      suggestedChips: _generateFollowupChips(question),
      isLiveAi: false,
    );
  }

  Future<String?> _callGeminiRest(
    String apiKey,
    String question,
    List<Map<String, String>> history,
  ) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final contents = <Map<String, dynamic>>[];
    for (final item in history) {
      contents.add({
        'role': item['role'] == 'user' ? 'user' : 'model',
        'parts': [
          {'text': item['text'] ?? ''}
        ],
      });
    }
    contents.add({
      'role': 'user',
      'parts': [
        {'text': question}
      ],
    });

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 800,
      },
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String?;
        }
      }
    }
    return null;
  }

  List<String> _generateFollowupChips(String question) {
    final q = question.toLowerCase();
    if (q.contains('pad') || q.contains('free') || q.contains('request')) {
      return const [
        'How does anonymous pickup work?',
        'Find nearest verified hub',
        'Can I request reusable pads?',
        'What is in a PadCare kraft kit?',
      ];
    } else if (q.contains('cramp') || q.contains('pain') || q.contains('ache')) {
      return const [
        'Gentle stretches for period cramps',
        'When should I see a doctor for cramps?',
        'Foods and teas that soothe cramps',
        'Request emergency heat compress pack',
      ];
    } else if (q.contains('hub') || q.contains('near') || q.contains('where')) {
      return const [
        'Kisenyi Health Center IV hours',
        'Is female caretaker on duty?',
        'Reserve discreet voucher code',
        'Live directions to dispensary',
      ];
    }
    return const [
      'Request free pads discreetly',
      'Severe cramps relief remedies',
      'Find safe distribution hub',
      'How does anonymous pickup work?',
    ];
  }

  String _getLocalCuratedResponse(String question) {
    final q = question.toLowerCase();

    if (q.contains('pad') || q.contains('request') || q.contains('free')) {
      return 'You can reserve free sanitary pads completely discreetly. No ID, phone number or name will be requested at the center.\n\n'
          'Once you tap "Get Code" in the app, you receive a confidential 6-character voucher (e.g. **PAD-749**). Walk to your chosen dispensary and show or whisper the code to receive your products sealed in an opaque kraft bag.\n\n'
          '💡 *Tip: You can configure your free Google Gemini API key in App Settings to enable live generative AI responses.*';
    } else if (q.contains('cramp') || q.contains('pain') || q.contains('relief')) {
      return 'For menstrual cramp discomfort, safe non-medical relief includes:\n'
          '• **Gentle Warmth**: Apply a warm water compress or bottle to your lower abdomen\n'
          '• **Hydration**: Drink warm water or chamomile/ginger tea to ease uterine muscle tension\n'
          '• **Light Movement**: Gentle pelvic rocking, child’s pose, or slow walking\n'
          '• **Rest**: Elevate your legs with a pillow under your knees\n\n'
          '⚠️ *Medical Notice*: If pain is unbearable, sudden, or accompanied by fever or heavy bleeding, please visit your nearest primary healthcare facility immediately.';
    } else if (q.contains('hub') || q.contains('find') || q.contains('where')) {
      return 'PadCare connects to verified safe collection hubs across Kampala and EAC corridors:\n'
          '• **Kisenyi Health Center IV** (850m away) - Open 24/7 with female caretakers\n'
          '• **WoMena Community Sanctuary** (1.4km) - Safe women’s space with private counters\n'
          '• **Mulago National Referral Hub** (1.8km) - Certified emergency dispensary\n\n'
          'Check the **Live Map** tab in the app for realtime walking directions and live stock levels!';
    } else if (q.contains('anonymous') || q.contains('pickup') || q.contains('work')) {
      return 'Anonymous pickup protects your dignity and privacy completely:\n'
          '1. Choose a nearby hub on the Live Map\n'
          '2. Tap "Reserve Discreet Pack"\n'
          '3. Your zero-trace voucher code (e.g. **PAD-749**) appears\n'
          '4. Walk to the counter and show the code\n'
          '5. Receive your sealed, unlabelled kraft bag. No registration or personal data required!';
    }

    return 'Thank you for reaching out to HerHelp. PadCare provides free menstrual hygiene products, verified private distribution hubs, and zero-judgment health guidance across Uganda and East Africa.\n\n'
        'How can I assist your menstrual health and dignity today?\n\n'
        '💡 *Connect your Gemini API Key in Settings to enable real-time conversational AI.*';
  }
}
