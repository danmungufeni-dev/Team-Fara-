enum UserRole {
  seeker,
  supplier,
  admin,
}

class UserProfile {
  final String id;
  final String pseudonym;
  final String email;
  final UserRole role;
  final String city;
  final String country;
  final DateTime joinedDate;
  final List<String> savedHubIds;
  final int activeRequestsCount;
  final int safelyCollectedCount;
  final bool incognitoMode;
  final bool biometricLock;
  final String selectedLocale;
  final String selectedTheme;
  final bool termsAccepted;

  const UserProfile({
    required this.id,
    required this.pseudonym,
    required this.email,
    this.role = UserRole.seeker,
    this.city = 'Kampala',
    this.country = 'Uganda',
    required this.joinedDate,
    this.savedHubIds = const ['hub_1', 'hub_3'],
    this.activeRequestsCount = 1,
    this.safelyCollectedCount = 4,
    this.incognitoMode = true,
    this.biometricLock = true,
    this.selectedLocale = 'en',
    this.selectedTheme = 'orchid',
    this.termsAccepted = true,
  });

  UserProfile copyWith({
    String? pseudonym,
    String? email,
    UserRole? role,
    String? city,
    String? country,
    List<String>? savedHubIds,
    int? activeRequestsCount,
    int? safelyCollectedCount,
    bool? incognitoMode,
    bool? biometricLock,
    String? selectedLocale,
    String? selectedTheme,
    bool? termsAccepted,
  }) {
    return UserProfile(
      id: id,
      pseudonym: pseudonym ?? this.pseudonym,
      email: email ?? this.email,
      role: role ?? this.role,
      city: city ?? this.city,
      country: country ?? this.country,
      joinedDate: joinedDate,
      savedHubIds: savedHubIds ?? this.savedHubIds,
      activeRequestsCount: activeRequestsCount ?? this.activeRequestsCount,
      safelyCollectedCount: safelyCollectedCount ?? this.safelyCollectedCount,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      biometricLock: biometricLock ?? this.biometricLock,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pseudonym': pseudonym,
        'email': email,
        'role': role.name,
        'city': city,
        'country': country,
        'joinedDate': joinedDate.toIso8601String(),
        'savedHubIds': savedHubIds,
        'activeRequestsCount': activeRequestsCount,
        'safelyCollectedCount': safelyCollectedCount,
        'incognitoMode': incognitoMode,
        'biometricLock': biometricLock,
        'selectedLocale': selectedLocale,
        'selectedTheme': selectedTheme,
        'termsAccepted': termsAccepted,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        pseudonym: json['pseudonym'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.seeker,
        ),
        city: json['city'] as String? ?? 'Kampala',
        country: json['country'] as String? ?? 'Uganda',
        joinedDate: DateTime.parse(json['joinedDate'] as String),
        savedHubIds: (json['savedHubIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['hub_1', 'hub_3'],
        activeRequestsCount: json['activeRequestsCount'] as int? ?? 1,
        safelyCollectedCount: json['safelyCollectedCount'] as int? ?? 4,
        incognitoMode: json['incognitoMode'] as bool? ?? true,
        biometricLock: json['biometricLock'] as bool? ?? true,
        selectedLocale: json['selectedLocale'] as String? ?? 'en',
        selectedTheme: json['selectedTheme'] as String? ?? 'orchid',
        termsAccepted: json['termsAccepted'] as bool? ?? true,
      );
}
