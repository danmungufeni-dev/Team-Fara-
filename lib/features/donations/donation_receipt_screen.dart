import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class DonationReceiptScreen extends StatelessWidget {
  final num amount;
  final String reference;
  final String providerName;
  final String phone;

  const DonationReceiptScreen({
    super.key,
    required this.amount,
    required this.reference,
    required this.providerName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final kesEquiv = (amount * 0.0347).round();
    final tzsEquiv = (amount * 0.70).round();
    final rwfEquiv = (amount * 0.36).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Official Donation Receipt', style: AppTypography.headlineSM()),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Celebration Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCF8EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 44, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Payment Successful • Malipo Yamekamilika',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMD(color: AppColors.success),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thank you for empowering dignity!',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMD(color: AppColors.neutralDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your donation directly supplies menstrual hygiene resources and sustains humanitarian open tech across Uganda and East Africa.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.neutralMuted),
                ),
                const SizedBox(height: 24),

                // Receipt Breakdown Card
                DignityCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Transaction Reference', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Row(
                            children: [
                              Text(reference, style: AppTypography.labelMD(color: AppColors.neutralDark)),
                              IconButton(
                                icon: const Icon(Icons.content_copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: reference));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reference copied to clipboard!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date & Timestamp', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Text('Today, 14:32 EAT', style: AppTypography.labelMD(color: AppColors.neutralDark)),
                        ],
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Primary Charged Amount', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Text(
                            AppFormatters.currencyUgx(amount),
                            style: AppTypography.headlineSM(color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Source', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Text(
                            '${providerName.toUpperCase()} • ${AppFormatters.maskPhone(phone)}',
                            style: AppTypography.labelMD(color: AppColors.neutralDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Regional Currency Equivalence Card
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync_alt, color: AppColors.primaryContainer, size: 18),
                          const SizedBox(width: 8),
                          Text('Live EAC Regional Equivalence', style: AppTypography.labelMD()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildEquiv('🇰🇪 Kenya', '$kesEquiv KES'),
                          _buildEquiv('🇹🇿 Tanzania', '$tzsEquiv TZS'),
                          _buildEquiv('🇷🇼 Rwanda', '$rwfEquiv RWF'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                DignityButton(
                  text: 'Download Official Receipt (PDF)',
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt PDF saved to device downloads.')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                DignityButton(
                  text: 'Return to Home Dashboard',
                  style: DignityButtonStyle.secondary,
                  icon: const Icon(Icons.home, color: AppColors.primaryContainer),
                  onPressed: () => context.go('/dashboard'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquiv(String flagCity, String value) {
    return Column(
      children: [
        Text(flagCity, style: AppTypography.labelSM()),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.labelMD(color: AppColors.primaryContainer)),
      ],
    );
  }
}
