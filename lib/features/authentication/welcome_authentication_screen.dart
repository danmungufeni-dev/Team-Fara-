import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/localization/app_locale.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_text_field.dart';
import '../../shared/widgets/language_selector_sheet.dart';

class WelcomeAuthenticationScreen extends StatefulWidget {
  const WelcomeAuthenticationScreen({super.key});

  @override
  State<WelcomeAuthenticationScreen> createState() =>
      _WelcomeAuthenticationScreenState();
}

class _WelcomeAuthenticationScreenState
    extends State<WelcomeAuthenticationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedCountryCode = '+256';
  SupportedLanguage _currentLang = AppLocales.swahili;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top status bar with Language Switcher and Encrypted Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user,
                              size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            'Encrypted • EAC Community',
                            style: AppTypography.labelSM(
                                color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        LanguageSelectorSheet.show(
                          context,
                          currentLocaleCode: _currentLang.code,
                          onSelect: (lang) {
                            setState(() => _currentLang = lang);
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
                              _currentLang.code.toUpperCase(),
                              style: AppTypography.labelSM(
                                  color: AppColors.neutralDark),
                            ),
                            const Icon(Icons.expand_more,
                                size: 16, color: AppColors.neutralMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // PadCare App Logo & Header
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppElevation.level2,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        AssetPaths.padcareIcon,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.spa, size: 40, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'PadCare',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineXL(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Care Within Reach • Menstrual Health & Dignity',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.neutralMuted),
                ),
                const SizedBox(height: 32),

                // Form Container Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DignityTextField(
                        controller: _nameController,
                        label: 'Full Name or Field Pseudonym',
                        hintText: 'e.g. Hope Seeker or Matron Harriet',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 16),
                      DignityTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'name@organization.org',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline,
                            color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 16),
                      DignityTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.primaryContainer),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.neutralMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue with Email button
                      DignityButton(
                        text: 'Continue with Email',
                        icon: const Icon(Icons.arrow_forward,
                            size: 20, color: Colors.white),
                        onPressed: () {
                          context.push('/terms-consent');
                        },
                      ),
                      const SizedBox(height: 16),

                      // Divider "Or continue with"
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.borderSubtle)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or continue with',
                              style: AppTypography.labelSM(
                                  color: AppColors.neutralMuted),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.borderSubtle)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign-In button
                      DignityButton(
                        text: 'Google',
                        style: DignityButtonStyle.outline,
                        icon: const Icon(Icons.account_circle,
                            color: AppColors.primaryContainer),
                        onPressed: () {
                          context.push('/terms-consent');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Phone quick country selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_android,
                          color: AppColors.primaryContainer, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Direct SMS / USSD Access:',
                        style: AppTypography.labelSM(),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedCountryCode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: '+256', child: Text('🇺🇬 +256')),
                          DropdownMenuItem(
                              value: '+254', child: Text('🇰🇪 +254')),
                          DropdownMenuItem(
                              value: '+250', child: Text('🇷🇼 +250')),
                          DropdownMenuItem(
                              value: '+255', child: Text('🇹🇿 +255')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCountryCode = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Carousel Onboarding Link
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.explore_outlined,
                        color: AppColors.primaryContainer),
                    label: Text(
                      'First time? View Onboarding Carousel',
                      style: AppTypography.labelMD(
                          color: AppColors.primaryContainer),
                    ),
                    onPressed: () => context.push('/onboarding'),
                  ),
                ),
                const SizedBox(height: 16),

                // Legal links
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    TextButton(
                      child: Text('Terms of Care',
                          style: AppTypography.labelSM(
                              color: AppColors.neutralMuted)),
                      onPressed: () => context.push('/terms-consent'),
                    ),
                    TextButton(
                      child: Text('Privacy Policy',
                          style: AppTypography.labelSM(
                              color: AppColors.neutralMuted)),
                      onPressed: () => context.push('/terms-consent'),
                    ),
                    TextButton(
                      child: Text('Support',
                          style: AppTypography.labelSM(
                              color: AppColors.neutralMuted)),
                      onPressed: () => context.push('/donations'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
