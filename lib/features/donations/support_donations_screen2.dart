import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/donation_model.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_text_field.dart';

class SupportDonationsScreen2 extends StatefulWidget {
  final num amount;
  final int kitPercent;
  final int devPercent;
  final String frequency;

  const SupportDonationsScreen2({
    super.key,
    required this.amount,
    required this.kitPercent,
    required this.devPercent,
    required this.frequency,
  });

  @override
  State<SupportDonationsScreen2> createState() =>
      _SupportDonationsScreen2State();
}

class _SupportDonationsScreen2State extends State<SupportDonationsScreen2> {
  PaymentProvider _selectedProvider = PaymentProvider.mtnMomo;
  final TextEditingController _phoneController =
      TextEditingController(text: '+256 772 449 881');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
            Text('Payment Method', style: AppTypography.headlineSM()),
            Text('Step 2 of 3 • Secure Mobile Gateway',
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
                // Order Summary Card
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Donation', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Text(
                            AppFormatters.currencyUgx(widget.amount),
                            style: AppTypography.headlineSM(color: AppColors.primaryContainer),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: AppRadius.fullBorder,
                        ),
                        child: Text(
                          '${widget.kitPercent}% Kits / ${widget.devPercent}% Dev',
                          style: AppTypography.labelSM(color: AppColors.primaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('Select East African Payment Gateway', style: AppTypography.labelLG()),
                const SizedBox(height: 12),

                // Payment Providers List with custom logo badges
                _buildProviderTile(
                  PaymentProvider.mtnMomo,
                  'MTN Mobile Money (Uganda)',
                  'Instant STK Prompt • *165#',
                  AssetPaths.payWithMoMo,
                ),
                _buildProviderTile(
                  PaymentProvider.airtelMoney,
                  'Airtel Money (Uganda & EAC)',
                  'Instant Push • *185#',
                  AssetPaths.payWithAirtelMoney,
                ),
                _buildProviderTile(
                  PaymentProvider.mPesa,
                  'M-Pesa (Kenya & Tanzania)',
                  'Safaricom / Vodacom STK Push',
                  AssetPaths.mPesaIcon,
                ),
                _buildProviderTile(
                  PaymentProvider.rwandaPay,
                  'Rwanda Pay / MoMo Rwanda',
                  'MTN / Airtel Rwanda Push',
                  AssetPaths.rwandaPayIcon,
                ),
                _buildProviderTile(
                  PaymentProvider.card,
                  'Debit / Credit Card',
                  'Visa, Mastercard & EAC UnionPay',
                  AssetPaths.visaMastercardIcon,
                ),
                const SizedBox(height: 16),

                // Phone number input
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Account / Phone Number', style: AppTypography.labelMD()),
                      const SizedBox(height: 6),
                      DignityTextField(
                        controller: _phoneController,
                        hintText: '+256 700 000 000',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_iphone, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A PIN prompt will be sent directly to your phone. Never share your mobile money PIN with anyone.',
                        style: AppTypography.labelSM(color: AppColors.neutralMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Proceed Button
                DignityButton(
                  text: 'Proceed to Authorization (Step 3)',
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    context.push(
                      '/donations-step3?amount=${widget.amount}&kit=${widget.kitPercent}&dev=${widget.devPercent}&provider=${_selectedProvider.name}&phone=${_phoneController.text.trim()}',
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderTile(
    PaymentProvider provider,
    String name,
    String desc,
    String assetPath,
  ) {
    final isSelected = _selectedProvider == provider;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedProvider = provider),
        borderRadius: AppRadius.cardBorder,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(
              color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected ? AppElevation.level1 : null,
          ),
          child: Row(
            children: [
              Radio<PaymentProvider>(
                value: provider,
                groupValue: _selectedProvider,
                activeColor: AppColors.primaryContainer,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProvider = val);
                },
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, color: AppColors.primaryContainer),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.labelMD(color: AppColors.neutralDark)),
                    Text(desc, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
