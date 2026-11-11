import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_chip.dart';
import '../../shared/widgets/language_selector_sheet.dart';
import '../../shared/widgets/voice_selector_sheet.dart';

class PadCareHomeDashboardScreen extends ConsumerStatefulWidget {
  const PadCareHomeDashboardScreen({super.key});

  @override
  ConsumerState<PadCareHomeDashboardScreen> createState() =>
      _PadCareHomeDashboardScreenState();
}

class _PadCareHomeDashboardScreenState
    extends ConsumerState<PadCareHomeDashboardScreen> {
  final MockBackendStore _store = MockBackendStore();
  String _selectedCategory = 'Sanitary Pads';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Sanitary Pads',
    'Reusable Kits',
    'Discreet Safe Spaces',
    'Tampons',
    'Menstrual Cups',
    'Pain Relief',
  ];

  void _showThemeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.bottomSheetBorder,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('colorProfile'), style: AppTypography.headlineSM()),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              ctx,
              'PadCare Orchid (Default)',
              'Classic dignified healthcare lavender',
              AppColors.primaryContainer,
              AppColorProfile.orchid,
            ),
            _buildThemeOption(
              ctx,
              'Emerald Wellness',
              'Calming herbal & sustainable green',
              const Color(0xFF248A65),
              AppColorProfile.emerald,
            ),
            _buildThemeOption(
              ctx,
              'Subtle Slate (Discreet)',
              'Neutral camouflage for public safety',
              const Color(0xFF5A616E),
              AppColorProfile.slateDiscreet,
            ),
            _buildThemeOption(
              ctx,
              'High-Contrast Warm',
              'Enhanced contrast for high-sun outdoor reading',
              const Color(0xFF701538),
              AppColorProfile.highContrastWarm,
            ),
            _buildThemeOption(
              ctx,
              'Night Mode / Dark Shield',
              'Low-light & AMOLED battery saver',
              const Color(0xFF141218),
              AppColorProfile.nightShield,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext ctx,
    String name,
    String desc,
    Color swatch,
    AppColorProfile profile,
  ) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: swatch, radius: 14),
      title: Text(name, style: AppTypography.labelMD()),
      subtitle: Text(desc, style: AppTypography.labelSM()),
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to $name'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(appLocaleProvider);
    final tts = ref.watch(ttsServiceProvider);
    final hubs = _store.hubs;
    final primaryHub = hubs.isNotEmpty ? hubs.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  AssetPaths.padcareIcon,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('appName'), style: AppTypography.labelLG()),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.primaryContainer),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'Kampala, Central',
                          style: AppTypography.labelSM(color: AppColors.neutralMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Text-to-Speech Speak Summary Action
          IconButton(
            icon: Icon(
              tts.isPlaying ? Icons.stop_circle : Icons.volume_up_outlined,
              color: tts.isPlaying ? AppColors.coralPink : AppColors.primaryContainer,
            ),
            tooltip: context.tr('listenWithVoice'),
            onPressed: () {
              if (tts.isPlaying) {
                tts.stop();
              } else {
                final summary =
                    '${context.tr('appName')}. ${context.tr('appTagline')}. ${context.tr('discreetPickup')}: ${context.tr('discreetPickupSub')}';
                tts.speak(summary, languageCode: currentLang.code);
              }
            },
          ),
          // Language Switcher Action
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate, size: 20),
                const SizedBox(width: 2),
                Text(
                  currentLang.code.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            tooltip: context.tr('selectLanguage'),
            onPressed: () {
              LanguageSelectorSheet.show(
                context,
                currentLocaleCode: currentLang.code,
                onSelect: (lang) {
                  ref.read(appLocaleProvider.notifier).setLanguage(lang);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: context.tr('theme'),
            onPressed: _showThemeDialog,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: context.tr('notifications'),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.coralPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active TTS Playback Banner
                  if (tts.isLoading || tts.isPlaying)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          if (tts.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.record_voice_over, size: 18, color: AppColors.primaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tts.isLoading
                                  ? 'Generating FreeAPI voice in ${currentLang.nativeName}...'
                                  : '${context.tr('playingAudio')} (${tts.selectedVoice?.name ?? 'FreeAPI'})',
                              style: AppTypography.labelSM(color: AppColors.primaryContainer),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, size: 18, color: AppColors.primaryContainer),
                            tooltip: context.tr('voiceSettings'),
                            onPressed: () {
                              VoiceSelectorSheet.show(context, currentLanguageCode: currentLang.code);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop, size: 18, color: AppColors.primaryContainer),
                            tooltip: context.tr('stopAudio'),
                            onPressed: tts.stop,
                          ),
                        ],
                      ),
                    ),

                  // Live Outreach Grid Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppElevation.level1,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.neutralMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: context.tr('searchPlaceholder'),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (q) {
                                    context.push('/map?q=$q');
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.mic_none, color: AppColors.primaryContainer),
                                tooltip: context.tr('herHelpAssistant'),
                                onPressed: () => context.push('/herhelp'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Makerere / Wandegeya, Kampala',
                                  style: AppTypography.labelSM(color: AppColors.neutralDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GPS accurate • < 35m',
                                style: AppTypography.labelSM(color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Category Pills
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat == _selectedCategory;
                        return DignityChip(
                          label: context.tr(cat),
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedCategory = cat),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Primary Highlight Card: Discreet Pickup Guaranteed
                  if (primaryHub != null)
                    DignityCard(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DignityBadge(
                                text: context.tr('discreetPickup'),
                                variant: DignityBadgeVariant.confidential,
                                icon: const Icon(Icons.lock, size: 14, color: AppColors.primaryContainer),
                              ),
                              const Spacer(),
                              Text(
                                '850m away',
                                style: AppTypography.labelSM(color: AppColors.neutralMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            primaryHub.name,
                            style: AppTypography.headlineSM(color: AppColors.neutralDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            primaryHub.address,
                            style: AppTypography.bodySM(color: AppColors.neutralMuted),
                          ),
                          const SizedBox(height: 14),

                          // Active reservation banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppRadius.mdBorder,
                              border: Border.all(color: AppColors.primaryFixed),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.inventory_2, color: AppColors.primaryContainer),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ready at Counter 3',
                                        style: AppTypography.labelMD(color: AppColors.neutralDark),
                                      ),
                                      Text(
                                        'Token: PAD-749 • No ID needed',
                                        style: AppTypography.bodySM(color: AppColors.primaryContainer),
                                      ),
                                    ],
                                  ),
                                ),
                                DignityButton(
                                  text: context.tr('getCode'),
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  onPressed: () => context.push('/requests'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick actions: Map & Directions
                          Row(
                            children: [
                              Expanded(
                                child: DignityButton(
                                  text: context.tr('map'),
                                  style: DignityButtonStyle.secondary,
                                  icon: const Icon(Icons.map, size: 18, color: AppColors.primaryContainer),
                                  onPressed: () => context.push('/map'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DignityButton(
                                  text: context.tr('directions'),
                                  style: DignityButtonStyle.outline,
                                  icon: const Icon(Icons.info_outline, size: 18, color: AppColors.primaryContainer),
                                  onPressed: () => context.push('/hub-details/${primaryHub.id}'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // HerHelp AI Assistant Floating Banner
                  InkWell(
                    onTap: () => context.push('/herhelp'),
                    borderRadius: AppRadius.cardBorder,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF713B83), Color(0xFF8E2E4E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: AppElevation.level2,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('herHelpAssistant'),
                                  style: AppTypography.labelLG(color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('herHelpSubtitle'),
                                  style: AppTypography.labelSM(color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nearby Distribution Points section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('nearbyHubs'),
                          style: AppTypography.headlineSM(color: AppColors.neutralDark),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/map'),
                        child: Text(
                          context.tr('explore'),
                          style: AppTypography.labelMD(color: AppColors.primaryContainer),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nearby Hubs List
                  ...hubs.map((hub) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DignityCard(
                          onTap: () => context.push('/hub-details/${hub.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.softLavender,
                                  borderRadius: AppRadius.mdBorder,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_hospital,
                                    color: AppColors.primaryContainer,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hub.name,
                                      style: AppTypography.labelMD(color: AppColors.neutralDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${hub.distanceMeters}m • ${hub.walkingTimeMinutes} min walk',
                                      style: AppTypography.labelSM(color: AppColors.neutralMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.neutralMuted),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Community Impact Card
                  DignityCard(
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.volunteer_activism, color: AppColors.primaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text(context.tr('communityImpact'), style: AppTypography.labelLG()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildImpactStat('10,420+', 'Packs Given'),
                            _buildImpactStat('450+', 'Active Hubs'),
                            _buildImpactStat('100%', context.tr('free')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (idx) {
          switch (idx) {
            case 0:
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
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildImpactStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineSM(color: AppColors.primaryContainer)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
      ],
    );
  }
}
