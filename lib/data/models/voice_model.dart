class VoiceModel {
  final int index;
  final String id;
  final String name;
  final String gender;
  final String language;
  final String country;
  final String engine;
  final String edgeVoice;
  final String edgeVoiceName;
  final String voiceMatch;

  const VoiceModel({
    required this.index,
    required this.id,
    required this.name,
    required this.gender,
    required this.language,
    required this.country,
    this.engine = 'edge',
    this.edgeVoice = '',
    this.edgeVoiceName = '',
    this.voiceMatch = 'exact',
  });

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      index: json['index'] as int? ?? 1,
      id: json['id'] as String? ?? 'voice-1',
      name: json['name'] as String? ?? 'Default Voice',
      gender: json['gender'] as String? ?? 'Female',
      language: json['language'] as String? ?? 'English',
      country: json['country'] as String? ?? 'United States',
      engine: json['engine'] as String? ?? 'edge',
      edgeVoice: json['edgeVoice'] as String? ?? '',
      edgeVoiceName: json['edgeVoiceName'] as String? ?? '',
      voiceMatch: json['voiceMatch'] as String? ?? 'exact',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'id': id,
      'name': name,
      'gender': gender,
      'language': language,
      'country': country,
      'engine': engine,
      'edgeVoice': edgeVoice,
      'edgeVoiceName': edgeVoiceName,
      'voiceMatch': voiceMatch,
    };
  }

  String get genderIcon => gender.toLowerCase() == 'male' ? '👨' : '👩';

  @override
  String toString() => '$name ($language, $gender)';
}
