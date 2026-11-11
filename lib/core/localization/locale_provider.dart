import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_backend_store.dart';
import '../constants/app_constants.dart';
import '../services/text_to_speech_service.dart';
import '../storage/local_storage.dart';
import 'app_locale.dart';

class AppLocaleNotifier extends Notifier<SupportedLanguage> {
  @override
  SupportedLanguage build() {
    final storedCode = LocalStorage.getString(AppConstants.storageKeySelectedLocale);
    if (storedCode != null && storedCode.isNotEmpty) {
      return AppLocales.fromCode(storedCode);
    }
    final userLocale = MockBackendStore().currentUser.selectedLocale;
    return AppLocales.fromCode(userLocale);
  }

  Future<void> setLanguage(SupportedLanguage language) async {
    state = language;
    await LocalStorage.setString(AppConstants.storageKeySelectedLocale, language.code);
    final store = MockBackendStore();
    store.currentUser = store.currentUser.copyWith(selectedLocale: language.code);
  }

  Future<void> setLocaleCode(String code) async {
    final lang = AppLocales.fromCode(code);
    await setLanguage(lang);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, SupportedLanguage>(() {
  return AppLocaleNotifier();
});

final currentLocaleProvider = Provider<Locale>((ref) {
  final lang = ref.watch(appLocaleProvider);
  return AppLocales.getLocale(lang.code);
});

final ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechService();
});
