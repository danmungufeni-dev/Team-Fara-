import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/donation_model.dart';
import '../../data/repositories/donation_repository.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class SupportDonationsScreen3 extends StatefulWidget {
  final num amount;
  final int kitPercent;
  final int devPercent;
  final String providerName;
  final String phone;

  const SupportDonationsScreen3({
    super.key,
    required this.amount,
    required this.kitPercent,
    required this.devPercent,
    required this.providerName,
    required this.phone,
  });

  @override
  State<SupportDonationsScreen3> createState() =>
      _SupportDonationsScreen3State();
}

class _SupportDonationsScreen3State extends State<SupportDonationsScreen3> {
  final DonationRepository _repo = DonationRepository();
  bool _isProcessing = false;

  Future<void> _completeDonation() async {
    setState(() => _isProcessing = true);

    PaymentProvider provider = PaymentProvider.mtnMomo;
    try {
      provider = PaymentProvider.values.firstWhere(
        (p) => p.name == widget.providerName,
        orElse: () => PaymentProvider.mtnMomo,
      );
    } catch (_) {}

    await _repo.processDonation(
      amountUgx: widget.amount,
      kitPercent: widget.kitPercent,
      devPercent: widget.devPercent,
      provider: provider,
      phoneNumber: widget.phone,
      frequency: DonationFrequency.oneTime,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      context.push(
        '/donation-receipt?amount=${widget.amount}&ref=TXN-EAC-202505-8842&provider=${widget.providerName}&phone=${widget.phone}',
      );
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review & Authorization', style: AppTypography.headlineSM()),
            Text('Step 3 of 3 • Developer Appreciation',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Developer Appreciation Spotlight Card
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.coralPink, size: 20),
                          const SizedBox(width: 8),
                          Text('Developer Appreciation Spotlight', style: AppTypography.labelLG()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Honoring the engineers sustaining PadCare open-source public health tech across East Africa.',
                        style: AppTypography.bodySM(color: AppColors.neutralMuted),
                      ),
                      const SizedBox(height: 16),

                      // Two Developers Showcase
                      Row(
                        children: [
                          // Developer 1: Dan Mungufeni
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.asset(
                                      AssetPaths.developerDan,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                        radius: 32,
                                        child: Icon(Icons.person),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dan Mungufeni',
                                    style: AppTypography.labelMD(color: AppColors.neutralDark),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Lead Architect',
                                    style: AppTypography.labelSM(color: AppColors.primaryContainer),
                                  ),
                                  Text(
                                    'devgtnation@gmail.com',
                                    style: AppTypography.labelSM(color: AppColors.neutralMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Developer 2: Nichlas Abeti
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.asset(
                                      AssetPaths.developerNichlas,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                        radius: 32,
                                        child: Icon(Icons.person),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nichlas Abeti',
                                    style: AppTypography.labelMD(color: AppColors.neutralDark),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Systems & Security',
                                    style: AppTypography.labelSM(color: AppColors.primaryContainer),
                                  ),
                                  Text(
                                    'abetinichlas@gmail.com',
                                    style: AppTypography.labelSM(color: AppColors.neutralMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Review Summary Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Breakdown', style: AppTypography.labelLG()),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Amount Charged', AppFormatters.currencyUgx(widget.amount), isBold: true),
                      const Divider(color: AppColors.borderSubtle),
                      _buildSummaryRow('PadCare Free Kits (${widget.kitPercent}%)', AppFormatters.currencyUgx((widget.amount * widget.kitPercent) / 100)),
                      const Divider(color: AppColors.borderSubtle),
                      _buildSummaryRow('Developer Sustenance (${widget.devPercent}%)', AppFormatters.currencyUgx((widget.amount * widget.devPercent) / 100)),
                      const Divider(color: AppColors.borderSubtle),
                      _buildSummaryRow('Payment Target', widget.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm Button
                DignityButton(
                  text: _isProcessing ? 'Triggering STK Push...' : 'Confirm & Complete Donation',
                  isLoading: _isProcessing,
                  icon: const Icon(Icons.lock, color: Colors.white),
                  onPressed: _isProcessing ? null : _completeDonation,
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    '🔒 256-bit Encrypted EAC Payment Gateway',
                    style: AppTypography.labelSM(color: AppColors.neutralMuted),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMD(color: AppColors.neutralMuted)),
          Text(
            value,
            style: isBold
                ? AppTypography.labelLG(color: AppColors.primaryContainer)
                : AppTypography.labelMD(color: AppColors.neutralDark),
          ),
        ],
      ),
    );
  }
}
