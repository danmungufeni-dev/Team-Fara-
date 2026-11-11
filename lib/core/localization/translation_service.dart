import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../storage/local_storage.dart';

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String targetLanguage;
  final bool isFromCache;
  final bool isSuccessful;
  final String? errorMessage;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.targetLanguage,
    this.isFromCache = false,
    this.isSuccessful = true,
    this.errorMessage,
  });
}

/// Service that integrates with the supplied Go Translation API:
/// POST /translate
/// { "text": "...", "to": "sw" }
class TranslationService {
  final ApiClient _apiClient;
  String _baseUrl;

  // In-memory cache for fast lookups
  static final Map<String, String> _cache = {};

  TranslationService({ApiClient? apiClient, String? baseUrl})
      : _apiClient = apiClient ?? ApiClient(),
        _baseUrl = baseUrl ?? _getInitialBaseUrl();

  static String _getInitialBaseUrl() {
    final stored = LocalStorage.getString('custom_translation_url');
    if (stored != null && stored.isNotEmpty) return stored;
    return const String.fromEnvironment(
      AppConstants.envTranslationApiUrl,
      defaultValue: AppConstants.defaultTranslationApiUrl,
    );
  }

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    LocalStorage.setString('custom_translation_url', newUrl);
  }

  String get baseUrl => _baseUrl;

  String _cacheKey(String text, String targetLang) => '$targetLang:${text.trim().toLowerCase()}';

  /// Primary translation method
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || targetLanguage.toLowerCase() == 'en') {
      return TranslationResult(
        originalText: text,
        translatedText: text,
        targetLanguage: targetLanguage,
      );
    }

    final key = _cacheKey(cleanText, targetLanguage);

    // 1. Check in-memory & stored cache
    if (_cache.containsKey(key)) {
      return TranslationResult(
        originalText: text,
        translatedText: _cache[key]!,
        targetLanguage: targetLanguage,
        isFromCache: true,
      );
    }

    final storedVal = LocalStorage.getString('trans_$key');
    if (storedVal != null && storedVal.isNotEmpty) {
      _cache[key] = storedVal;
      return TranslationResult(
        originalText: text,
        translatedText: storedVal,
        targetLanguage: targetLanguage,
        isFromCache: true,
      );
    }

    // 2. Offline fallback dictionary for essential healthcare phrases
    final offlineMatch = _lookupOfflineDictionary(cleanText, targetLanguage);
    if (offlineMatch != null) {
      _cache[key] = offlineMatch;
      return TranslationResult(
        originalText: text,
        translatedText: offlineMatch,
        targetLanguage: targetLanguage,
        isFromCache: true,
      );
    }

    // 3. Call Go translation API
    try {
      final uri = Uri.parse('$_baseUrl/translate');
      final payload = {
        'text': cleanText,
        'to': targetLanguage,
      };

      final response = await _apiClient.postJson(uri, body: payload);

      final status = response['status'] as bool? ?? false;
      final translated = response['translatedText'] as String?;

      if (status && translated != null && translated.isNotEmpty) {
        _cache[key] = translated;
        await LocalStorage.setString('trans_$key', translated);
        return TranslationResult(
          originalText: text,
          translatedText: translated,
          targetLanguage: targetLanguage,
          isSuccessful: true,
        );
      } else {
        final msg = response['message'] as String? ?? 'Translation failed';
        if (kDebugMode) debugPrint('⚠️ [TranslationService] Server error: $msg');
        return TranslationResult(
          originalText: text,
          translatedText: text,
          targetLanguage: targetLanguage,
          isSuccessful: false,
          errorMessage: msg,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [TranslationService] Network error: $e');
      // Preserves original text without crashing
      return TranslationResult(
        originalText: text,
        translatedText: text,
        targetLanguage: targetLanguage,
        isSuccessful: false,
        errorMessage: e.toString(),
      );
    }
  }

  String? _lookupOfflineDictionary(String text, String lang) {
    final lower = text.toLowerCase();
    final dict = _commonPhrases[lang.toLowerCase()];
    if (dict != null) {
      for (final entry in dict.entries) {
        if (lower.contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }
    return null;
  }

  static const Map<String, Map<String, String>> _commonPhrases = {
    'sw': {
      'dignity': 'heshima',
      'sanitary pad': 'taulo ya kike',
      'safe space': 'mahali salama',
      'free': 'bure',
      'available': 'inapatikana',
      'pickup': 'kuchukua',
      'confidential': 'siri',
    },
    'lg': {
      'dignity': 'ekitiibwa',
      'sanitary pad': 'pedi z’abakazi',
      'safe space': 'ekifo ekikuume',
      'free': 'bwereere',
      'available': 'weeri',
      'pickup': 'okunona',
      'confidential': 'kyama',
    },
    'fr': {
      'dignity': 'dignité',
      'sanitary pad': 'serviette hygiénique',
      'safe space': 'espace sécurisé',
      'free': 'gratuit',
      'available': 'disponible',
      'pickup': 'retrait',
      'confidential': 'confidentiel',
    },
  };
}
