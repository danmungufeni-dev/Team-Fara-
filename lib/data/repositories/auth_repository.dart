import '../models/user_profile.dart';
import '../services/mock_backend_store.dart';
import '../../core/storage/secure_storage.dart';

abstract class IAuthRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile> signInWithEmail(String email, String password, {String? pseudonym});
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
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<UserProfile> getCurrentUser() async {
    return _store.currentUser;
  }

  @override
  Future<UserProfile> signInWithEmail(
    String email,
    String password, {
    String? pseudonym,
  }) async {
    await SecureStorage.writeToken('auth_token', 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
    _store.currentUser = _store.currentUser.copyWith(
      email: email,
      pseudonym: pseudonym ?? _store.currentUser.pseudonym,
    );
    return _store.currentUser;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    await SecureStorage.writeToken('auth_token', 'mock_google_token');
    return _store.currentUser;
  }

  @override
  Future<bool> verifyOtp(String code) async {
    return code.length == 6;
  }

  @override
  Future<void> acceptTerms() async {
    _store.currentUser = _store.currentUser.copyWith(termsAccepted: true);
  }

  @override
  Future<void> updateRole(UserRole role) async {
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
    await SecureStorage.deleteToken('auth_token');
  }

  @override
  Future<void> emergencyWipe() async {
    await SecureStorage.wipeAllSensitive();
    _store.messages.clear();
    _store.notifications.clear();
  }
}
