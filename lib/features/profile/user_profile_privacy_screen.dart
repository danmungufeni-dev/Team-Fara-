import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/localization/app_locale.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/discreet_camouflage_view.dart';
import '../../shared/widgets/language_selector_sheet.dart';

class UserProfilePrivacyScreen extends StatefulWidget {
  const UserProfilePrivacyScreen({super.key});

  @override
  State<UserProfilePrivacyScreen> createState() =>
      _UserProfilePrivacyScreenState();
}

class _UserProfilePrivacyScreenState extends State<UserProfilePrivacyScreen> {
  final MockBackendStore _store = MockBackendStore();
  bool _isCamouflage = false;

  void _emergencyReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Emergency Data Reset'),
          ],
        ),
        content: const Text(
          'This will instantly destroy all local voucher codes, message logs, and cached search history from this device. Are you sure?',
        ),
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

  @override
  Widget build(BuildContext context) {
    if (_isCamouflage) {
      return DiscreetCamouflageView(
        onExitCamouflage: () => setState(() => _isCamouflage = false),
      );
    }

    final user = _store.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile & Privacy Settings', style: AppTypography.headlineSM()),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.bolt, color: AppColors.coralPink, size: 18),
            label: Text('Quick Exit', style: AppTypography.labelSM(color: AppColors.coralPink)),
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

                // Section 1: Privacy & Dignity Shield
                Text('Privacy & Dignity Shield', style: AppTypography.labelLG()),
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
                        title: const Text('Biometric / Passkey Protection'),
                        subtitle: const Text('Require fingerprint to reveal voucher pickup codes.'),
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
                        title: const Text('Discreet Calculator Camouflage'),
                        subtitle: const Text('One-tap disguised calculator to hide screen.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _isCamouflage = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Localization & Language
                Text('Navigation & Language', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  onTap: () {
                    LanguageSelectorSheet.show(
                      context,
                      currentLocaleCode: user.selectedLocale,
                      onSelect: (lang) {
                        setState(() {
                          _store.currentUser = user.copyWith(selectedLocale: lang.code);
                        });
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
                            Text('App Language', style: AppTypography.labelMD()),
                            Text(
                              AppLocales.fromCode(user.selectedLocale).nativeName,
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

                // Section 3: Field Role Workflows Switcher
                Text('Portal & Field Access', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.storefront, color: AppColors.primaryContainer),
                        title: const Text('Supplier / Dispensary Dashboard'),
                        subtitle: const Text('Dispensary counter PIN verification.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/supplier'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inventory, color: AppColors.primaryContainer),
                        title: const Text('Stock Management'),
                        subtitle: const Text('Real-time supply ledger and intake.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/stock'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.admin_panel_settings, color: AppColors.primaryContainer),
                        title: const Text('Admin Verification HQ'),
                        subtitle: const Text('Kampala Central Grid oversight.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin'),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.sync, color: AppColors.primaryContainer),
                        title: const Text('Full Offline Sync Manager'),
                        subtitle: const Text('2G / Edge Mesh queue and conflict resolver.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/sync'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Legal & Policy
                Text('Guidance & Rights', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                DignityCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.policy_outlined, color: AppColors.neutralMuted),
                        title: const Text('Terms of Use & Conditions'),
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
                  text: 'Emergency Data Reset (Wipe All)',
                  style: DignityButtonStyle.accent,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  onPressed: _emergencyReset,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.logout, color: AppColors.neutralMuted, size: 18),
                    label: Text('Sign Out', style: AppTypography.labelMD(color: AppColors.neutralMuted)),
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
