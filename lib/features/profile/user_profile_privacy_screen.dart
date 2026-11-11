import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/storage/local_storage.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/discreet_camouflage_view.dart';
import '../../shared/widgets/language_selector_sheet.dart';
import '../../shared/widgets/voice_selector_sheet.dart';

class UserProfilePrivacyScreen extends ConsumerStatefulWidget {
  const UserProfilePrivacyScreen({super.key});

  @override
  ConsumerState<UserProfilePrivacyScreen> createState() =>
      _UserProfilePrivacyScreenState();
}

class _UserProfilePrivacyScreenState
    extends ConsumerState<UserProfilePrivacyScreen> {
  final MockBackendStore _store = MockBackendStore();
  bool _isCamouflage = false;

  void _emergencyReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(context.tr('emergencyReset')),
          ],
        ),
        content: Text(context.tr('emergencyResetSub')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _store.messages.clear();
              _store.notifications.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All local data wiped permanently.'),
                  backgroundColor: AppColors.error,
                ),
              );
              context.go('/welcome');
            },
            child: const Text('Erase All Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupabaseConfigSheet() {
    final urlController = TextEditingController(
      text: LocalStorage.getString(AppConstants.storageKeySupabaseUrl) ?? '',
    );
    final keyController = TextEditingController(
      text: LocalStorage.getString(AppConstants.storageKeySupabaseAnonKey) ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(Icons.bolt, color: AppColors.primaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Supabase Realtime Backend & Auth', style: AppTypography.headlineSM()),
                        Text(
                          SupabaseService.instance.isLiveSupabase
                              ? '⚡ Live Supabase Connected'
                              : 'Free Realtime Mode (Offline-first)',
                          style: AppTypography.labelSM(
                            color: SupabaseService.instance.isLiveSupabase
                                ? AppColors.success
                                : AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'PadCare runs with free realtime auth, database sync, and live tracking powered by Supabase. Enter your Supabase project credentials to synchronize with your cloud PostgreSQL database.',
                style: AppTypography.bodySM(color: AppColors.neutralMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Supabase Project URL',
                  hintText: 'https://xyzcompany.supabase.co',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Supabase Anon / Public Key',
                  hintText: 'eyJhbGciOi...',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final url = urlController.text.trim();
                        final key = keyController.text.trim();
                        if (url.isNotEmpty && key.isNotEmpty) {
                          final ok = await SupabaseService.instance.updateCredentials(
                            url: url,
                            anonKey: key,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? '⚡ Connected to live Supabase backend!'
                                    : 'Saved. Running in offline/simulation mode.'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save & Connect'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGeminiConfigSheet() {
    final keyController = TextEditingController(
      text: LocalStorage.getString(AppConstants.storageKeyGeminiApiKey) ?? '',
    );
    final hasKey = GeminiService.instance.hasApiKey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.primaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HerHelp Gemini AI Engine', style: AppTypography.headlineSM()),
                        Text(
                          hasKey
                              ? '✨ Live Gemini 1.5 Flash Active'
                              : 'Configure Free Gemini API Key',
                          style: AppTypography.labelSM(
                            color: hasKey ? AppColors.success : AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'HerHelp uses Google Gemini 1.5 Flash for confidential, compassionate menstrual health guidance. Enter your free API key from Google AI Studio to unlock live generative responses.',
                style: AppTypography.bodySM(color: AppColors.neutralMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Google Gemini API Key',
                  hintText: hasKey ? '••••••••••••••••••••' : 'AIzaSy...',
                  prefixIcon: const Icon(Icons.key, color: AppColors.primaryContainer),
                  border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final key = keyController.text.trim();
                        if (key.isNotEmpty) {
                          await GeminiService.instance.setApiKey(key);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✨ Gemini API Key saved successfully!'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save Key'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCamouflage) {
      return DiscreetCamouflageView(
        onExitCamouflage: () => setState(() => _isCamouflage = false),
      );
    }

    final currentLang = ref.watch(appLocaleProvider);
    final tts = ref.watch(ttsServiceProvider);
    final user = _store.currentUser;
    final activeVoice = tts.selectedVoice ?? tts.getDefaultVoiceForLanguage(currentLang.code);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('profile'), style: AppTypography.headlineSM()),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.bolt, color: AppColors.coralPink, size: 18),
            label: Text(context.tr('quickExit'), style: AppTypography.labelSM(color: AppColors.coralPink)),
            onPressed: () => setState(() => _isCamouflage = true),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seeker Profile Header Card
                DignityCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.softLavender,
                            child: const Icon(Icons.person, size: 36, color: AppColors.primaryContainer),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(user.pseudonym, style: AppTypography.headlineSM()),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 16, color: AppColors.success),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PadCare Member • ${user.city} • Joined Aug 2024',
                                  style: AppTypography.bodySM(color: AppColors.neutralMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderSubtle),
                      const SizedBox(height: 12),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol('2 Hubs', 'Saved Locations', Icons.bookmark),
                          Container(width: 1, height: 32, color: AppColors.borderSubtle),
                          _buildStatCol('1 Active', 'Pending Voucher', Icons.lock_clock),
                          Container(width: 1, height: 32, color: AppColors.borderSubtle),
                          _buildStatCol('4 Packs', 'Safely Collected', Icons.check_circle),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 1: Localization & Language (Primary feature)
                Text(context.tr('navigationLanguage'), style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  onTap: () {
                    LanguageSelectorSheet.show(
                      context,
                      currentLocaleCode: currentLang.code,
                      onSelect: (lang) {
                        ref.read(appLocaleProvider.notifier).setLanguage(lang);
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.translate, color: AppColors.primaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('language'), style: AppTypography.labelMD()),
                            Text(
                              '${currentLang.flag} ${currentLang.nativeName} (${currentLang.name})',
                              style: AppTypography.bodySM(color: AppColors.primaryContainer),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.neutralMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Text-to-Speech & FreeAPI Voices
                Text(context.tr('voiceSettings'), style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.record_voice_over, color: AppColors.primaryContainer),
                        title: Text(context.tr('voiceLabel'), style: AppTypography.labelMD()),
                        subtitle: Text(
                          '${activeVoice.genderIcon} ${activeVoice.name} • ${activeVoice.language} (${activeVoice.country})',
                          style: AppTypography.bodySM(color: AppColors.neutralDark),
                        ),
                        trailing: const Icon(Icons.tune, color: AppColors.primaryContainer),
                        onTap: () {
                          VoiceSelectorSheet.show(context, currentLanguageCode: currentLang.code);
                        },
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            icon: Icon(
                              tts.isPlaying ? Icons.stop_circle : Icons.play_arrow,
                              color: AppColors.primaryContainer,
                            ),
                            label: Text(
                              tts.isPlaying ? context.tr('stopAudio') : context.tr('testVoice'),
                              style: AppTypography.labelMD(color: AppColors.primaryContainer),
                            ),
                            onPressed: () {
                              if (tts.isPlaying) {
                                tts.stop();
                              } else {
                                final sample = currentLang.code == 'sw'
                                    ? 'Habari! Sauti hii ya FreeAPI inafanya kazi vizuri kwenye PadCare.'
                                    : currentLang.code == 'fr'
                                        ? 'Bonjour! Cette voix FreeAPI fonctionne parfaitement sur PadCare.'
                                        : currentLang.code == 'ar'
                                            ? 'مرحباً! هذا الصوت يعمل بنجاح مع تطبيق باد كير.'
                                            : 'Hello! This FreeAPI text to speech voice is fully integrated and active on PadCare.';
                                tts.speak(sample, voice: activeVoice, languageCode: currentLang.code);
                              }
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              VoiceSelectorSheet.show(context, currentLanguageCode: currentLang.code);
                            },
                            child: const Text('Browse 580+ Voices'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 3: Privacy & Dignity Shield
                Text(context.tr('privacyShield'), style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: user.incognitoMode,
                        activeThumbColor: AppColors.primaryContainer,
                        title: const Text('Incognito Seeker Browsing'),
                        subtitle: const Text('Masks device identity and prevents search suggestions.'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            _store.currentUser = user.copyWith(incognitoMode: val);
                          });
                        },
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      SwitchListTile(
                        value: user.biometricLock,
                        activeThumbColor: AppColors.primaryContainer,
                        title: Text(context.tr('biometricProtection')),
                        subtitle: Text(context.tr('biometricSub')),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            _store.currentUser = user.copyWith(biometricLock: val);
                          });
                        },
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.visibility_off, color: AppColors.primaryContainer),
                        title: Text(context.tr('calculatorCamouflage')),
                        subtitle: Text(context.tr('calculatorCamouflageSub')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _isCamouflage = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Field Role Workflows Switcher
                Text(context.tr('portalAccess'), style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.storefront, color: AppColors.primaryContainer),
                        title: Text(context.tr('supplierDashboard')),
                        subtitle: const Text('Dispensary counter PIN verification.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/supplier'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inventory, color: AppColors.primaryContainer),
                        title: Text(context.tr('stockManagement')),
                        subtitle: const Text('Real-time supply ledger and intake.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/stock'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.admin_panel_settings, color: AppColors.primaryContainer),
                        title: Text(context.tr('adminVerification')),
                        subtitle: const Text('Kampala Central Grid oversight.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.sync, color: AppColors.primaryContainer),
                        title: Text(context.tr('offlineQueue')),
                        subtitle: const Text('2G / Edge Mesh queue and conflict resolver.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/sync'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 5: Realtime Backend & Gemini AI Settings
                Text('Cloud & Intelligence Services', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.bolt, color: AppColors.primaryContainer),
                        title: const Text('Realtime Backend & Auth'),
                        subtitle: Text(
                          SupabaseService.instance.isLiveSupabase
                              ? '⚡ Live Supabase Connected'
                              : 'Free Realtime Engine (Offline-First Active)',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SupabaseService.instance.isLiveSupabase
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.secondaryContainer,
                            borderRadius: AppRadius.fullBorder,
                          ),
                          child: Text(
                            SupabaseService.instance.isLiveSupabase ? 'Online' : 'Free Demo',
                            style: AppTypography.labelSM(
                              color: SupabaseService.instance.isLiveSupabase
                                  ? AppColors.success
                                  : AppColors.primaryContainer,
                            ),
                          ),
                        ),
                        onTap: _showSupabaseConfigSheet,
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.auto_awesome, color: AppColors.primaryContainer),
                        title: const Text('HerHelp Assistant (Gemini AI)'),
                        subtitle: Text(
                          GeminiService.instance.hasApiKey
                              ? 'Google Gemini 1.5 Flash Connected'
                              : 'Tap to configure free Gemini API Key',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GeminiService.instance.hasApiKey
                                ? AppColors.primaryContainer.withValues(alpha: 0.15)
                                : AppColors.softLavender,
                            borderRadius: AppRadius.fullBorder,
                          ),
                          child: Text(
                            GeminiService.instance.hasApiKey ? '✨ Active' : 'Setup',
                            style: AppTypography.labelSM(color: AppColors.primaryContainer),
                          ),
                        ),
                        onTap: _showGeminiConfigSheet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 6: Legal & Policy
                Text('Guidance & Rights', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.policy_outlined, color: AppColors.neutralMuted),
                        title: Text(context.tr('termsAndConsent')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/terms-consent'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.neutralMuted),
                        title: const Text('Privacy Policy (Doc 3)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/terms-consent'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Emergency Reset Button
                DignityButton(
                  text: context.tr('emergencyReset'),
                  style: DignityButtonStyle.accent,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  onPressed: _emergencyReset,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.logout, color: AppColors.neutralMuted, size: 18),
                    label: Text(context.tr('quickExit'), style: AppTypography.labelMD(color: AppColors.neutralMuted)),
                    onPressed: () => context.go('/welcome'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (idx) {
          switch (idx) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.push('/map');
              break;
            case 2:
              context.push('/requests');
              break;
            case 3:
              context.push('/donations');
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatCol(String count, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryContainer, size: 20),
        const SizedBox(height: 4),
        Text(count, style: AppTypography.labelMD(color: AppColors.neutralDark)),
        Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
      ],
    );
  }
}
