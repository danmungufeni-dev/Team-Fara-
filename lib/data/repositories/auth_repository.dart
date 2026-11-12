import '../models/user_profile.dart';
import '../services/mock_backend_store.dart';
import '../../core/services/supabase_service.dart';
import '../../core/storage/secure_storage.dart';

abstract class IAuthRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile> signInWithEmail(String email, String password, {String? pseudonym});
  Future<UserProfile> signInAnonymously({String? pseudonym});
  Future<UserProfile> signInWithGoogle();
  Future<bool> verifyOtp(String code);
  Future<void> acceptTerms();
  Future<void> updateRole(UserRole role);
  Future<void> updateLocale(String localeCode);
  Future<void> updateTheme(String themeName);
  Future<void> toggleIncognito(bool enabled);
  Future<void> signOut();
  Future<void> emergencyWipe();
}

class AuthRepository implements IAuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<UserProfile> getCurrentUser() async => _supabase.currentUser;

  @override
  Future<UserProfile> signInWithEmail(
    String email,
    String password, {
    String? pseudonym,
  }) {
    return _supabase.signInWithEmail(email: email, password: password);
  }

  @override
  Future<UserProfile> signInAnonymously({String? pseudonym}) {
    return _supabase.signInAnonymously(pseudonym: pseudonym);
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    // Do not report a successful Google login using a fabricated token.
    // Configure a real Supabase OAuth flow before enabling this action.
    throw UnsupportedError(
      'Google sign-in is not configured yet. Use a configured sign-in method.',
    );
  }

  @override
  Future<bool> verifyOtp(String code) async {
    // A six-digit shape check is not proof that an OTP is valid. Verification
    // must be performed by Supabase Auth or a trusted server endpoint.
    throw UnsupportedError(
      'OTP verification is not configured. No code has been verified.',
    );
  }

  @override
  Future<void> acceptTerms() async {
    _store.currentUser = _store.currentUser.copyWith(termsAccepted: true);
  }

  @override
  Future<void> updateRole(UserRole role) async {
    // This is local UI state only. Authorization roles must be assigned and
    // enforced by trusted backend policy, not by client-side state.
    _store.currentUser = _store.currentUser.copyWith(role: role);
  }

  @override
  Future<void> updateLocale(String localeCode) async {
    _store.currentUser = _store.currentUser.copyWith(selectedLocale: localeCode);
  }

  @override
  Future<void> updateTheme(String themeName) async {
    _store.currentUser = _store.currentUser.copyWith(selectedTheme: themeName);
  }

  @override
  Future<void> toggleIncognito(bool enabled) async {
    _store.currentUser = _store.currentUser.copyWith(incognitoMode: enabled);
  }

  @override
  Future<void> signOut() async {
    await _supabase.signOut();
  }

  @override
  Future<void> emergencyWipe() async {
    await _supabase.signOut();
    await SecureStorage.wipeAllSensitive();
    _store.messages.clear();
    _store.notifications.clear();
  }
}
