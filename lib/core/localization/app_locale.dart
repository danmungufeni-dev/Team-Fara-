import 'package:flutter/material.dart';

class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRtl = false,
    required this.flag,
  });
}

abstract class AppLocales {
  static const SupportedLanguage english = SupportedLanguage(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
  );

  static const SupportedLanguage swahili = SupportedLanguage(
    code: 'sw',
    name: 'Swahili',
    nativeName: 'Kiswahili',
    flag: '🇹🇿',
  );

  static const SupportedLanguage luganda = SupportedLanguage(
    code: 'lg',
    name: 'Luganda',
    nativeName: 'Oluganda',
    flag: '🇺🇬',
  );

  static const SupportedLanguage french = SupportedLanguage(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
  );

  static const SupportedLanguage arabic = SupportedLanguage(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
    flag: '🇸🇦',
  );

  static const SupportedLanguage spanish = SupportedLanguage(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
  );

  static const SupportedLanguage luo = SupportedLanguage(
    code: 'luo',
    name: 'Luo',
    nativeName: 'Dholuo',
    flag: '🇺🇬',
  );

  static const SupportedLanguage german = SupportedLanguage(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
  );

  static const SupportedLanguage portuguese = SupportedLanguage(
    code: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flag: '🇵🇹',
  );

  static const SupportedLanguage amharic = SupportedLanguage(
    code: 'am',
    name: 'Amharic',
    nativeName: 'አማርኛ',
    flag: '🇪🇹',
  );

  static const SupportedLanguage hindi = SupportedLanguage(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    flag: '🇮🇳',
  );

  static const List<SupportedLanguage> all = [
    english,
    swahili,
    luganda,
    french,
    arabic,
    spanish,
    luo,
    german,
    portuguese,
    amharic,
    hindi,
  ];

  static SupportedLanguage fromCode(String code) {
    return all.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => english,
    );
  }

  static Locale getLocale(String code) {
    final lang = fromCode(code);
    return Locale(lang.code);
  }

  static bool isRtl(String code) {
    return fromCode(code).isRtl;
  }
}
