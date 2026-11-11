import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../../data/models/voice_model.dart';
import '../storage/local_storage.dart';

enum TtsPlaybackState { idle, loading, playing, paused, error }

class TextToSpeechService extends ChangeNotifier {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  List<VoiceModel> _voices = [];
  bool _isLoadingVoices = false;
  TtsPlaybackState _state = TtsPlaybackState.idle;
  String? _currentlySpeakingText;
  String? _errorMessage;
  VoiceModel? _selectedVoice;
  int _pitch = 0; // -100 to 100
  int _rate = 0; // -100 to 100

  static const String _voicesApiUrl = 'https://freeapi.pro/api/voices';
  static const String _ttsApiUrl = 'https://freeapi.pro/api/tts';
  static const String _storageKeyVoices = 'padcare_cached_voices';
  static const String _storageKeySelectedVoiceId = 'padcare_selected_voice_id';

  TextToSpeechService._internal() {
    _initAudioListeners();
    _loadVoicesFromCache();
    fetchVoices();
  }

  // Getters
  List<VoiceModel> get voices => List.unmodifiable(_voices);
  bool get isLoadingVoices => _isLoadingVoices;
  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isLoading => _state == TtsPlaybackState.loading;
  String? get currentlySpeakingText => _currentlySpeakingText;
  String? get errorMessage => _errorMessage;
  VoiceModel? get selectedVoice => _selectedVoice;
  int get pitch => _pitch;
  int get rate => _rate;

  void setPitch(int value) {
    _pitch = value.clamp(-100, 100);
    notifyListeners();
  }

  void setRate(int value) {
    _rate = value.clamp(-100, 100);
    notifyListeners();
  }

  void setSelectedVoice(VoiceModel voice) {
    _selectedVoice = voice;
    LocalStorage.setString(_storageKeySelectedVoiceId, voice.id);
    notifyListeners();
  }

  void _initAudioListeners() {
    _player.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.playing) {
        _state = TtsPlaybackState.playing;
      } else if (playerState == PlayerState.paused) {
        _state = TtsPlaybackState.paused;
      } else if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
        _state = TtsPlaybackState.idle;
        _currentlySpeakingText = null;
      }
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      _state = TtsPlaybackState.idle;
      _currentlySpeakingText = null;
      notifyListeners();
    });
  }

  void _loadVoicesFromCache() {
    try {
      final cachedJson = LocalStorage.getJson(_voicesApiUrl) ?? LocalStorage.getJson(_storageKeyVoices);
      if (cachedJson is List && cachedJson.isNotEmpty) {
        _voices = cachedJson.map((e) => VoiceModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}

    if (_voices.isEmpty) {
      _voices = _defaultFallbackVoices();
    }

    final savedId = LocalStorage.getString(_storageKeySelectedVoiceId);
    if (savedId != null) {
      _selectedVoice = _voices.cast<VoiceModel?>().firstWhere(
            (v) => v?.id == savedId,
            orElse: () => null,
          );
    }
  }

  /// Fetches voices from curl "https://freeapi.pro/api/voices"
  Future<List<VoiceModel>> fetchVoices({bool forceRefresh = false}) async {
    if (_voices.isNotEmpty && !forceRefresh && !_isLoadingVoices) {
      return _voices;
    }

    _isLoadingVoices = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_voicesApiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['voices'] is List) {
          final list = (data['voices'] as List)
              .map((item) => VoiceModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();

          if (list.isNotEmpty) {
            _voices = list;
            await LocalStorage.setJson(_storageKeyVoices, list.map((v) => v.toJson()).toList());
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [TTS] Failed to fetch voices from API: $e');
      if (_voices.isEmpty) {
        _voices = _defaultFallbackVoices();
      }
    } finally {
      _isLoadingVoices = false;
      notifyListeners();
    }

    return _voices;
  }

  /// Finds voices matching a specific language code (e.g. 'sw', 'en', 'fr', 'ar', 'lg')
  List<VoiceModel> getVoicesForLanguage(String languageCode) {
    if (_voices.isEmpty) {
      _voices = _defaultFallbackVoices();
    }

    final code = languageCode.toLowerCase();
    final List<VoiceModel> matches = [];

    // Map common codes to FreeAPI language names
    final targetLangNames = _mapCodeToLanguageNames(code);

    for (final v in _voices) {
      final vLang = v.language.toLowerCase();
      if (targetLangNames.any((t) => vLang.contains(t))) {
        matches.add(v);
      }
    }

    // Always append Multilingual voices as capable universal fallbacks
    for (final v in _voices) {
      if (v.language.toLowerCase() == 'multilingual' && !matches.contains(v)) {
        matches.add(v);
      }
    }

    if (matches.isEmpty) {
      return _voices.take(15).toList();
    }

    return matches;
  }

  /// Gets the best default voice for a language code
  VoiceModel getDefaultVoiceForLanguage(String languageCode) {
    if (_selectedVoice != null && _isVoiceCompatibleWithLanguage(_selectedVoice!, languageCode)) {
      return _selectedVoice!;
    }

    final candidates = getVoicesForLanguage(languageCode);
    if (candidates.isNotEmpty) {
      // Prefer exact female voice for healthcare companion HerHelp, or first match
      final female = candidates.firstWhere(
        (v) => v.gender.toLowerCase() == 'female',
        orElse: () => candidates.first,
      );
      return female;
    }

    return _voices.isNotEmpty ? _voices.first : _defaultFallbackVoices().first;
  }

  bool _isVoiceCompatibleWithLanguage(VoiceModel voice, String languageCode) {
    final vLang = voice.language.toLowerCase();
    if (vLang == 'multilingual') return true;
    final names = _mapCodeToLanguageNames(languageCode.toLowerCase());
    return names.any((name) => vLang.contains(name));
  }

  List<String> _mapCodeToLanguageNames(String code) {
    switch (code) {
      case 'sw':
        return ['swahili'];
      case 'lg':
      case 'luo':
        return ['luganda', 'swahili', 'multilingual'];
      case 'fr':
        return ['french'];
      case 'ar':
        return ['arabic'];
      case 'es':
        return ['spanish', 'mexican'];
      case 'de':
        return ['german'];
      case 'pt':
        return ['portuguese'];
      case 'am':
        return ['amharic'];
      case 'hi':
        return ['hindi'];
      case 'en':
      default:
        return ['english', 'multilingual'];
    }
  }

  /// Synthesizes text to speech audio bytes (MP3) using POST /api/tts
  Future<Uint8List?> synthesize({
    required String text,
    VoiceModel? voice,
    int? voiceIndex,
    String? languageCode,
    int? pitch,
    int? rate,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return null;

    final targetVoice = voice ??
        (voiceIndex != null
            ? _voices.firstWhere((v) => v.index == voiceIndex, orElse: () => _voices.first)
            : (languageCode != null ? getDefaultVoiceForLanguage(languageCode) : (_selectedVoice ?? _voices.first)));

    final payload = {
      'voiceIndex': targetVoice.index,
      'voice': targetVoice.id,
      'text': cleanText.length > 1800 ? cleanText.substring(0, 1800) : cleanText,
      'pitch': pitch ?? _pitch,
      'rate': rate ?? _rate,
    };

    try {
      final response = await http.post(
        Uri.parse(_ttsApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': '*/*',
          'Origin': 'https://freeapi.pro',
          'Referer': 'https://freeapi.pro/speech',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200 && response.bodyBytes.length > 100) {
        return response.bodyBytes;
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ [TTS] Synthesis returned status ${response.statusCode}: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ [TTS] Synthesis network error: $e');
      return null;
    }
  }

  /// Speaks text aloud using FreeAPI TTS and the AudioPlayer
  Future<bool> speak(
    String text, {
    VoiceModel? voice,
    String? languageCode,
    int? pitch,
    int? rate,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return false;

    // If already speaking the same text, toggle stop
    if (_state == TtsPlaybackState.playing && _currentlySpeakingText == cleanText) {
      await stop();
      return false;
    }

    try {
      await stop();

      _state = TtsPlaybackState.loading;
      _currentlySpeakingText = cleanText;
      _errorMessage = null;
      notifyListeners();

      final bytes = await synthesize(
        text: cleanText,
        voice: voice,
        languageCode: languageCode,
        pitch: pitch,
        rate: rate,
      );

      if (bytes == null || bytes.isEmpty) {
        _state = TtsPlaybackState.error;
        _errorMessage = 'Could not generate speech audio. Please check network connection.';
        notifyListeners();
        return false;
      }

      _state = TtsPlaybackState.playing;
      notifyListeners();

      await _player.play(BytesSource(bytes));
      return true;
    } catch (e) {
      _state = TtsPlaybackState.error;
      _errorMessage = 'Playback error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _state = TtsPlaybackState.paused;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await _player.resume();
      _state = TtsPlaybackState.playing;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _state = TtsPlaybackState.idle;
    _currentlySpeakingText = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// Reliable built-in fallback voices directly from FreeAPI database
  static List<VoiceModel> _defaultFallbackVoices() {
    return const [
      VoiceModel(
        index: 1,
        id: 'voice-107',
        name: 'Andrew Multilingual',
        gender: 'Male',
        language: 'Multilingual',
        country: 'United States',
        edgeVoice: 'en-US-AndrewMultilingualNeural',
        edgeVoiceName: 'Andrew Multilingual',
      ),
      VoiceModel(
        index: 2,
        id: 'voice-110',
        name: 'Ava Multilingual',
        gender: 'Female',
        language: 'Multilingual',
        country: 'United States',
        edgeVoice: 'en-US-AvaMultilingualNeural',
        edgeVoiceName: 'Ava Multilingual',
      ),
      VoiceModel(
        index: 3,
        id: 'voice-115',
        name: 'Emma Multilingual',
        gender: 'Female',
        language: 'Multilingual',
        country: 'United States',
        edgeVoice: 'en-US-EmmaMultilingualNeural',
        edgeVoiceName: 'Emma Multilingual',
      ),
      VoiceModel(
        index: 14,
        id: 'voice-109',
        name: 'Aria',
        gender: 'Female',
        language: 'English',
        country: 'United States',
        edgeVoice: 'en-US-AriaNeural',
        edgeVoiceName: 'Aria',
      ),
      VoiceModel(
        index: 21,
        id: 'voice-119',
        name: 'Jenny',
        gender: 'Female',
        language: 'English',
        country: 'United States',
        edgeVoice: 'en-US-JennyNeural',
        edgeVoiceName: 'Jenny',
      ),
      VoiceModel(
        index: 298,
        id: 'voice-298',
        name: 'Rehema',
        gender: 'Female',
        language: 'Swahili',
        country: 'Tanzania',
        edgeVoice: 'sw-TZ-RehemaNeural',
        edgeVoiceName: 'Rehema',
      ),
      VoiceModel(
        index: 297,
        id: 'voice-297',
        name: 'Daudi',
        gender: 'Male',
        language: 'Swahili',
        country: 'Tanzania',
        edgeVoice: 'sw-TZ-DaudiNeural',
        edgeVoiceName: 'Daudi',
      ),
      VoiceModel(
        index: 140,
        id: 'voice-140',
        name: 'Denise',
        gender: 'Female',
        language: 'French',
        country: 'France',
        edgeVoice: 'fr-FR-DeniseNeural',
        edgeVoiceName: 'Denise',
      ),
      VoiceModel(
        index: 26,
        id: 'voice-26',
        name: 'Amina',
        gender: 'Female',
        language: 'Arabic',
        country: 'Egypt',
        edgeVoice: 'ar-EG-SalmaNeural',
        edgeVoiceName: 'Salma',
      ),
      VoiceModel(
        index: 125,
        id: 'voice-125',
        name: 'Elvira',
        gender: 'Female',
        language: 'Spanish',
        country: 'Spain',
        edgeVoice: 'es-ES-ElviraNeural',
        edgeVoiceName: 'Elvira',
      ),
      VoiceModel(
        index: 153,
        id: 'voice-153',
        name: 'Katja',
        gender: 'Female',
        language: 'German',
        country: 'Germany',
        edgeVoice: 'de-DE-KatjaNeural',
        edgeVoiceName: 'Katja',
      ),
      VoiceModel(
        index: 220,
        id: 'voice-220',
        name: 'Francisca',
        gender: 'Female',
        language: 'Portuguese',
        country: 'Brazil',
        edgeVoice: 'pt-BR-FranciscaNeural',
        edgeVoiceName: 'Francisca',
      ),
      VoiceModel(
        index: 171,
        id: 'voice-171',
        name: 'Swara',
        gender: 'Female',
        language: 'Hindi',
        country: 'India',
        edgeVoice: 'hi-IN-SwaraNeural',
        edgeVoiceName: 'Swara',
      ),
      VoiceModel(
        index: 25,
        id: 'voice-25',
        name: 'Mekdes',
        gender: 'Female',
        language: 'Amharic',
        country: 'Ethiopia',
        edgeVoice: 'am-ET-MekdesNeural',
        edgeVoiceName: 'Mekdes',
      ),
    ];
  }
}
