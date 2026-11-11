import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/core/localization/translation_service.dart';
import 'package:padcare/core/storage/local_storage.dart';

void main() {
  setUp(() async {
    await LocalStorage.init();
  });

  group('TranslationService Tests', () {
    test('Translating empty text returns empty text without error', () async {
      final service = TranslationService();
      final result = await service.translate(text: '', targetLanguage: 'sw');
      expect(result.translatedText, '');
      expect(result.isSuccessful, true);
    });

    test('Translating to English returns original text directly', () async {
      final service = TranslationService();
      final result = await service.translate(text: 'Dignity first', targetLanguage: 'en');
      expect(result.translatedText, 'Dignity first');
      expect(result.isSuccessful, true);
    });

    test('Offline dictionary translates healthcare phrases', () async {
      final service = TranslationService();
      final result = await service.translate(text: 'dignity', targetLanguage: 'sw');
      expect(result.translatedText.toLowerCase(), 'heshima');
      expect(result.isFromCache, true);
    });

    test('Offline dictionary translates to French', () async {
      final service = TranslationService();
      final result = await service.translate(text: 'free', targetLanguage: 'fr');
      expect(result.translatedText.toLowerCase(), 'gratuit');
    });

    test('Gracefully fallbacks to original text on unreachable backend', () async {
      final service = TranslationService(baseUrl: 'http://invalid-fake-host-999.test');
      final result = await service.translate(text: 'Community hygiene protocol', targetLanguage: 'sw');
      // Must not crash or throw, returns original text
      expect(result.translatedText, 'Community hygiene protocol');
      expect(result.isSuccessful, false);
    });
  });
}
