import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/language_selector_sheet.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String badgeText;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.badgeText,
  });
}

class UserOnboardingScreen extends ConsumerStatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  ConsumerState<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends ConsumerState<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Dignity First',
      subtitle: '450+ Verified Community Hubs',
      description:
          'Access free sanitary pads and reusable kits across schools, maternal clinics, and trusted rural kiosks in Uganda and East Africa.',
      icon: Icons.volunteer_activism,
      badgeText: 'Slide 1 of 4 • Dignity First',
    ),
    OnboardingSlide(
      title: '100% Discreet & Confidential',
      subtitle: 'Zero National ID Checks',
      description:
          'Collect supplies with simple 6-character token codes (e.g. PAD-749). No names recorded, no identity card required, packaged in opaque kraft bags.',
      icon: Icons.lock_person,
      badgeText: 'Slide 2 of 4 • Absolute Privacy',
    ),
    OnboardingSlide(
      title: 'Works Without Internet',
      subtitle: 'Instant Offline Queue & USSD',
      description:
          'Designed for low-connectivity environments. Queue requests locally and sync automatically when network is reached, or use free SMS tokens.',
      icon: Icons.signal_cellular_alt_2_bar,
      badgeText: 'Slide 3 of 4 • Offline Resilient',
    ),
    OnboardingSlide(
      title: 'Sustainable Care & Education',
      subtitle: 'Reusable AFRIpads & HerHelp AI',
      description:
          'Washable reusable kits and private 24/7 reproductive health guidance with zero medical bias or stigmatizing data collection.',
      icon: Icons.spa,
      badgeText: 'Slide 4 of 4 • Health & Community',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(appLocaleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Top header bar with language switcher and privacy chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        LanguageSelectorSheet.show(
                          context,
                          currentLocaleCode: currentLang.code,
                          onSelect: (lang) {
                            ref.read(appLocaleProvider.notifier).setLanguage(lang);
                          },
                        );
                      },
                      borderRadius: AppRadius.fullBorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: AppRadius.fullBorder,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.translate,
                                size: 16, color: AppColors.primaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              currentLang.code.toUpperCase(),
                              style: AppTypography.labelSM(),
                            ),
                            const Icon(Icons.expand_more,
                                size: 16, color: AppColors.neutralMuted),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock,
                              size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('discreetPickup'),
                            style: AppTypography.labelSM(
                                color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Carousel Body
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Central Icon Container
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 64,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppRadius.fullBorder,
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              'Slide ${index + 1} of ${_slides.length}',
                              style: AppTypography.labelSM(
                                  color: AppColors.primaryContainer),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Slide Titles
                          Text(
                            context.tr(slide.title),
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineMD(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr(slide.subtitle),
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLG(
                                color: AppColors.primaryContainer),
                          ),
                          const SizedBox(height: 14),

                          // Slide Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              context.tr(slide.description),
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMD(
                                  color: AppColors.neutralMuted),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Carousel Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: DignityButton(
                        text: context.tr('signIn'),
                        style: DignityButtonStyle.outline,
                        onPressed: () => context.go('/welcome'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DignityButton(
                        text: _currentPage == _slides.length - 1
                            ? context.tr('getStarted')
                            : context.tr('next'),
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(
                    'Skip to Hubs (Guest Mode)',
                    style: AppTypography.labelMD(color: AppColors.neutralMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
