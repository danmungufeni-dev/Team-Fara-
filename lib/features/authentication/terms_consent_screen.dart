import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class TermsConsentScreen extends StatefulWidget {
  const TermsConsentScreen({super.key});

  @override
  State<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends State<TermsConsentScreen> {
  bool _consentEssential = true;
  bool _consentOffline = true;
  bool _consentReporting = true;
  bool _expandedTerms = false;
  bool _expandedPrivacy = false;

  bool get _canProceed => _consentEssential;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Terms & Consent', style: AppTypography.headlineSM()),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF8EC),
              borderRadius: AppRadius.fullBorder,
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Dignity Shield', style: AppTypography.labelSM(color: AppColors.success)),
              ],
            ),
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
                // Header Banner
                Text(
                  'Terms of Use & Privacy Consent',
                  style: AppTypography.headlineMD(color: AppColors.neutralDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_note, size: 14, color: AppColors.neutralMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Effective 10 November 2026 • Uganda & East Africa',
                      style: AppTypography.labelSM(color: AppColors.neutralMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dignity Commitments Cards
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    children: [
                      _buildPledgeItem(
                        icon: Icons.health_and_safety,
                        title: 'Zero Cycle Tracking',
                        subtitle: 'Absolute bodily privacy. We never log or predict your personal menstrual cycles.',
                      ),
                      const Divider(color: AppColors.borderSubtle, height: 24),
                      _buildPledgeItem(
                        icon: Icons.location_off,
                        title: 'Location Off by Default',
                        subtitle: 'Search manually or activate GPS only when viewing nearby distribution hubs.',
                      ),
                      const Divider(color: AppColors.borderSubtle, height: 24),
                      _buildPledgeItem(
                        icon: Icons.lock,
                        title: 'Zero-Knowledge Tokens',
                        subtitle: 'No national ID or real names required. Only simple 6-digit collection tokens.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Expandable Terms Summary
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _expandedTerms = !_expandedTerms),
                        child: Row(
                          children: [
                            const Icon(Icons.policy_outlined, color: AppColors.primaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Terms of Service Details',
                                style: AppTypography.labelLG(color: AppColors.neutralDark),
                              ),
                            ),
                            Icon(
                              _expandedTerms ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.neutralMuted,
                            ),
                          ],
                        ),
                      ),
                      if (_expandedTerms) ...[
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderSubtle),
                        Text(
                          'PadCare operates in Uganda to connect seekers with free menstrual products across schools, primary health units, and community sanctuaries. Collection point details are verified periodically, but stock availability is subject to physical intake. Commercial resale of free dignity kits is strictly prohibited. For inquiries, email padcareforher@gmail.com.',
                          style: AppTypography.bodySM(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Expandable Privacy Policy Summary
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _expandedPrivacy = !_expandedPrivacy),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppColors.primaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Privacy Policy & Zero-Data Guarantee',
                                style: AppTypography.labelLG(color: AppColors.neutralDark),
                              ),
                            ),
                            Icon(
                              _expandedPrivacy ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.neutralMuted,
                            ),
                          ],
                        ),
                      ),
                      if (_expandedPrivacy) ...[
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderSubtle),
                        Text(
                          'In accordance with Ugandan data protection standards, PadCare collects only the bare minimum data required to facilitate anonymous pickup vouchers. We do not sell data, track browsing across third-party websites, or retain identifying medical logs. Anonymous session logs can be wiped at any moment via the Emergency Data Reset button.',
                          style: AppTypography.bodySM(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Consent Checkboxes
                Text(
                  'Community Consent Options',
                  style: AppTypography.labelLG(color: AppColors.neutralDark),
                ),
                const SizedBox(height: 8),

                _buildCheckboxTile(
                  value: _consentEssential,
                  title: 'Essential Service Operation (Required)',
                  subtitle: 'Allow PadCare to generate anonymous token codes and match you with safe clinics.',
                  onChanged: (val) => setState(() => _consentEssential = val ?? true),
                ),
                _buildCheckboxTile(
                  value: _consentOffline,
                  title: 'Offline Queue & Local Diagnostics',
                  subtitle: 'Save pending voucher actions securely in device storage when out of cellular range.',
                  onChanged: (val) => setState(() => _consentOffline = val ?? false),
                ),
                _buildCheckboxTile(
                  value: _consentReporting,
                  title: 'Voluntary Anonymized Impact Reporting',
                  subtitle: 'Include anonymous tally metrics in donor supply restock reports.',
                  onChanged: (val) => setState(() => _consentReporting = val ?? false),
                ),
                const SizedBox(height: 24),

                // Accept button
                DignityButton(
                  text: 'Accept & Enter Safe Space',
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  onPressed: _canProceed
                      ? () => context.go('/security-verification')
                      : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPledgeItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.mdBorder,
          ),
          child: Icon(icon, color: AppColors.primaryContainer, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLG(color: AppColors.neutralDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required String title,
    required String subtitle,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryContainer,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(title, style: AppTypography.labelMD(color: AppColors.neutralDark)),
        subtitle: Text(subtitle, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
      ),
    );
  }
}
