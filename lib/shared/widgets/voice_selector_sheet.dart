import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../data/models/voice_model.dart';

class VoiceSelectorSheet extends StatefulWidget {
  final String currentLanguageCode;

  const VoiceSelectorSheet({
    super.key,
    required this.currentLanguageCode,
  });

  static Future<void> show(BuildContext context, {required String currentLanguageCode}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceSelectorSheet(currentLanguageCode: currentLanguageCode),
    );
  }

  @override
  State<VoiceSelectorSheet> createState() => _VoiceSelectorSheetState();
}

class _VoiceSelectorSheetState extends State<VoiceSelectorSheet> {
  final TextToSpeechService _tts = TextToSpeechService();
  bool _showAllVoices = false;
  late VoiceModel _selectedVoice;

  @override
  void initState() {
    super.initState();
    _selectedVoice = _tts.selectedVoice ?? _tts.getDefaultVoiceForLanguage(widget.currentLanguageCode);
  }

  void _testSample(VoiceModel voice) {
    final sampleText = widget.currentLanguageCode.toLowerCase() == 'sw'
        ? 'Habari, mimi ni msaidizi wako wa PadCare. Karibu kwenye kituo salama.'
        : widget.currentLanguageCode.toLowerCase() == 'fr'
            ? 'Bonjour, je suis votre assistante PadCare. Bienvenue dans votre espace sécurisé.'
            : widget.currentLanguageCode.toLowerCase() == 'ar'
                ? 'مرحباً، أنا مساعدة باد كير. أهلاً بك في مساحتك الآمنة.'
                : 'Hello, I am your PadCare companion. Welcome to your safe health space.';

    _tts.speak(
      sampleText,
      voice: voice,
      languageCode: widget.currentLanguageCode,
      pitch: _tts.pitch,
      rate: _tts.rate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedVoices = _showAllVoices
        ? _tts.voices
        : _tts.getVoicesForLanguage(widget.currentLanguageCode);

    return AnimatedBuilder(
      animation: _tts,
      builder: (context, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.bottomSheetBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over, color: AppColors.primaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('voiceSettings'),
                          style: AppTypography.headlineSM(),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _tts.stop();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Playback Status Bar if speaking or loading
              if (_tts.isLoading || _tts.isPlaying)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Row(
                    children: [
                      _tts.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.volume_up, color: AppColors.primaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _tts.isLoading
                              ? 'Synthesizing voice from FreeAPI...'
                              : 'Playing sample: ${_selectedVoice.name}',
                          style: AppTypography.labelSM(color: AppColors.primaryContainer),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop, color: AppColors.primaryContainer),
                        onPressed: _tts.stop,
                      ),
                    ],
                  ),
                ),

              // Pitch & Speed Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${context.tr('pitchLabel')}: ${_tts.pitch}', style: AppTypography.labelSM()),
                          Slider(
                            value: _tts.pitch.toDouble(),
                            min: -50,
                            max: 50,
                            divisions: 20,
                            activeColor: AppColors.primaryContainer,
                            onChanged: (val) => _tts.setPitch(val.round()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${context.tr('speedLabel')}: ${_tts.rate}', style: AppTypography.labelSM()),
                          Slider(
                            value: _tts.rate.toDouble(),
                            min: -50,
                            max: 50,
                            divisions: 20,
                            activeColor: AppColors.primaryContainer,
                            onChanged: (val) => _tts.setRate(val.round()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filter toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showAllVoices
                          ? 'Showing All 580+ FreeAPI Voices'
                          : 'Voices for ${widget.currentLanguageCode.toUpperCase()} (${displayedVoices.length} found)',
                      style: AppTypography.labelSM(color: AppColors.neutralMuted),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _showAllVoices = !_showAllVoices);
                      },
                      child: Text(_showAllVoices ? 'Filter by Language' : 'Show All Voices'),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderSubtle, height: 1),

              // Voices List
              Expanded(
                child: ListView.separated(
                  itemCount: displayedVoices.length,
                  separatorBuilder: (context, _) => const Divider(
                    height: 1,
                    color: AppColors.borderSubtle,
                    indent: 20,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    final voice = displayedVoices[index];
                    final isSelected = _selectedVoice.id == voice.id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                        child: Text(
                          voice.genderIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        voice.name,
                        style: AppTypography.bodyMD(
                          color: isSelected ? AppColors.primaryContainer : AppColors.onSurface,
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${voice.language} • ${voice.country} (${voice.gender})',
                        style: AppTypography.labelSM(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: AppColors.primaryContainer),
                            tooltip: 'Test voice sample',
                            onPressed: () {
                              setState(() => _selectedVoice = voice);
                              _tts.setSelectedVoice(voice);
                              _testSample(voice);
                            },
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryContainer,
                            ),
                        ],
                      ),
                      onTap: () {
                        setState(() => _selectedVoice = voice);
                        _tts.setSelectedVoice(voice);
                        _testSample(voice);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
