import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/core/localization/app_locale.dart';

void main() {
  group('AppLocales & Localization Tests', () {
    test('Arabic locale correctly identifies as RTL', () {
      expect(AppLocales.isRtl('ar'), true);
      expect(AppLocales.fromCode('ar').isRtl, true);
    });

    test('English and Swahili are LTR', () {
      expect(AppLocales.isRtl('en'), false);
      expect(AppLocales.isRtl('sw'), false);
      expect(AppLocales.isRtl('lg'), false);
    });

    test('All required African and international languages exist', () {
      final codes = AppLocales.all.map((l) => l.code).toList();
      expect(codes, containsAll(['en', 'sw', 'lg', 'fr', 'ar', 'es', 'luo', 'de', 'pt', 'am', 'hi']));
    });

    test('Fallback to English for unknown code', () {
      final lang = AppLocales.fromCode('xyz');
      expect(lang.code, 'en');
    });
  });
}
