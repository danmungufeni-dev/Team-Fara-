import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key});

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  String _pin = '';
  String _activeMethod = 'sms';
  bool _isVerified = false;

  void _onKeyPress(String val) {
    if (_isVerified) return;
    if (_pin.length < 6) {
      setState(() {
        _pin += val;
      });
      if (_pin.length == 6) {
        _verifyCode();
      }
    }
  }

  void _onBackspace() {
    if (_isVerified) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyCode() {
    setState(() => _isVerified = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Security Verification', style: AppTypography.headlineSM()),
        elevation: 0,
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Security Trust Indicators
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSecurityChip(Icons.verified_user, 'E2E 256-bit Encrypted'),
                    _buildSecurityChip(Icons.security, 'Zero Data Logs'),
                    _buildSecurityChip(Icons.cell_tower, 'East Africa Node'),
                  ],
                ),
                const SizedBox(height: 20),

                // Method selection card
                DignityCard(
                  child: Column(
                    children: [
                      Text(
                        'Two-Step Verification',
                        style: AppTypography.headlineSM(color: AppColors.neutralDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confirm your access key to safeguard confidential seeker tokens.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySM(color: AppColors.neutralMuted),
                      ),
                      const SizedBox(height: 16),

                      // Tabs for verification type
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMethodPill('sms', 'Phone SMS', Icons.sms),
                            const SizedBox(width: 8),
                            _buildMethodPill('email', 'Email Code', Icons.alternate_email),
                            const SizedBox(width: 8),
                            _buildMethodPill('auth', 'Authenticator', Icons.security),
                            const SizedBox(width: 8),
                            _buildMethodPill('passkey', 'Passkey', Icons.fingerprint),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_iphone, size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            'Code sent to: +256 701 ••• 389',
                            style: AppTypography.labelMD(color: AppColors.primaryContainer),
                          ),
                          const SizedBox(width: 8),
                          Text('Edit', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 6-digit visual PIN boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          final isFilled = index < _pin.length;
                          final isActive = index == _pin.length;
                          return Container(
                            width: 44,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: AppRadius.mdBorder,
                              border: Border.all(
                                color: _isVerified
                                    ? AppColors.success
                                    : (isActive
                                        ? AppColors.primaryContainer
                                        : AppColors.borderSubtle),
                                width: isActive || _isVerified ? 2.0 : 1.0,
                              ),
                              boxShadow: isActive ? AppElevation.level1 : null,
                            ),
                            child: Center(
                              child: isFilled
                                  ? Text(
                                      '•',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _isVerified
                                            ? AppColors.success
                                            : AppColors.primaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Success banner if verified
                if (_isVerified)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF8EC),
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(
                          'Verified • Entering Dashboard...',
                          style: AppTypography.labelMD(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Numeric Keypad
                _buildKeypad(),
                const SizedBox(height: 16),

                // Biometric test button
                Row(
                  children: [
                    Expanded(
                      child: DignityButton(
                        text: 'Test Biometric Sensor',
                        style: DignityButtonStyle.secondary,
                        icon: const Icon(Icons.fingerprint, color: AppColors.primaryContainer),
                        onPressed: () {
                          setState(() {
                            _pin = '749884';
                            _verifyCode();
                          });
                        },
                      ),
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

  Widget _buildSecurityChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.softLavender,
        borderRadius: AppRadius.fullBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryContainer),
          const SizedBox(width: 4),
          Text(text, style: AppTypography.labelSM(color: AppColors.primaryContainer)),
        ],
      ),
    );
  }

  Widget _buildMethodPill(String id, String label, IconData icon) {
    final isSelected = _activeMethod == id;
    return InkWell(
      onTap: () => setState(() => _activeMethod = id),
      borderRadius: AppRadius.fullBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.neutralMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSM(
                color: isSelected ? Colors.white : AppColors.neutralDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['#', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return SizedBox(
                width: 76,
                height: 52,
                child: Material(
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  child: InkWell(
                    borderRadius: AppRadius.mdBorder,
                    onTap: () {
                      if (key == '⌫') {
                        _onBackspace();
                      } else {
                        _onKeyPress(key);
                      }
                    },
                    child: Center(
                      child: key == '⌫'
                          ? const Icon(Icons.backspace_outlined, size: 20, color: AppColors.neutralDark)
                          : Text(
                              key,
                              style: AppTypography.headlineMD(color: AppColors.neutralDark),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
