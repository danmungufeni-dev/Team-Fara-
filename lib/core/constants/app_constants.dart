/// Global application constants for PadCare.
abstract class AppConstants {
  static const String appName = 'PadCare';
  static const String appTagline = 'Care Within Reach • Menstrual Health & Dignity';
  static const String appVersion = '3.4.1 (EAC Community Release)';
  static const String contactEmail = 'padcareforher@gmail.com';
  static const String countryUganda = 'Uganda';
  static const String defaultCity = 'Kampala';

  // Environment variable keys
  static const String envTranslationApiUrl = 'TRANSLATION_API_URL';
  static const String defaultTranslationApiUrl = 'http://localhost:8000';
  static const String envGoogleMapsApiKey = 'GOOGLE_MAPS_API_KEY';
  static const String envSupabaseUrl = 'SUPABASE_URL';
  static const String envSupabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const String envGeminiApiKey = 'GEMINI_API_KEY';

  // Storage keys
  static const String storageKeyUserToken = 'padcare_auth_token';
  static const String storageKeyUserProfile = 'padcare_user_profile';
  static const String storageKeySelectedLocale = 'padcare_selected_locale';
  static const String storageKeySelectedTheme = 'padcare_selected_theme';
  static const String storageKeyOfflineQueue = 'padcare_offline_queue';
  static const String storageKeySavedHubs = 'padcare_saved_hubs';
  static const String storageKeyTermsAccepted = 'padcare_terms_accepted';
  static const String storageKeySupabaseUrl = 'padcare_supabase_url';
  static const String storageKeySupabaseAnonKey = 'padcare_supabase_anon_key';
  static const String storageKeyGeminiApiKey = 'padcare_gemini_api_key';

  // Seeker Default Voucher
  static const String defaultVoucherCode = 'PAD-749';
  static const String defaultHubName = 'Kisenyi Health Center IV';
}
