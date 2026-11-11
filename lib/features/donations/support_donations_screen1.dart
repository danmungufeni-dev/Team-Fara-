import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class SupportDonationsScreen1 extends StatefulWidget {
  const SupportDonationsScreen1({super.key});

  @override
  State<SupportDonationsScreen1> createState() =>
      _SupportDonationsScreen1State();
}

class _SupportDonationsScreen1State extends State<SupportDonationsScreen1> {
  num _selectedAmount = 15000;
  int _kitPercent = 80;
  int _devPercent = 20;
  String _frequency = 'One-time';

  final List<num> _amounts = const [5000, 15000, 35000, 75000];

  void _setSplit(int kit, int dev) {
    setState(() {
      _kitPercent = kit;
      _devPercent = dev;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kitAmount = (_selectedAmount * _kitPercent) / 100;
    final devAmount = (_selectedAmount * _devPercent) / 100;

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
            Text('Support & Donations', style: AppTypography.headlineSM()),
            Text('Empowering PadCare & Developers',
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
                // Impact metric badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('10,000+', 'Packs Delivered', Icons.inventory_2),
                    _buildMetric('4 Nations', 'UG, KE, RW & TZ', Icons.public),
                    _buildMetric('100%', 'Transparent', Icons.verified_user),
                  ],
                ),
                const SizedBox(height: 20),

                // Allocation Split Box
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Target Allocation', style: AppTypography.labelLG()),
                          Text('Customizable Split',
                              style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Preset buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSplitBtn('80/20 (Recommended)', 80, 20),
                            const SizedBox(width: 8),
                            _buildSplitBtn('50/50 Equal', 50, 50),
                            const SizedBox(width: 8),
                            _buildSplitBtn('100% Kits', 100, 0),
                            const SizedBox(width: 8),
                            _buildSplitBtn('100% Dev', 0, 100),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Allocation distribution bars
                      Row(
                        children: [
                          Expanded(
                            flex: _kitPercent > 0 ? _kitPercent : 1,
                            child: Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: _devPercent > 0 ? _devPercent : 1,
                            child: Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.coralPink,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, color: AppColors.primaryContainer),
                              const SizedBox(width: 6),
                              Text('PadCare Kits: $_kitPercent% (${AppFormatters.currencyUgx(kitAmount)})',
                                  style: AppTypography.labelSM()),
                            ],
                          ),
                          Row(
                            children: [
                              Container(width: 12, height: 12, color: AppColors.coralPink),
                              const SizedBox(width: 6),
                              Text('Devs: $_devPercent% (${AppFormatters.currencyUgx(devAmount)})',
                                  style: AppTypography.labelSM()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Selection
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Donation Amount', style: AppTypography.labelLG()),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amounts.map((amt) {
                          final isSelected = amt == _selectedAmount;
                          return ChoiceChip(
                            label: Text(AppFormatters.currencyUgx(amt)),
                            selected: isSelected,
                            selectedColor: AppColors.primaryContainer,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.neutralDark,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _selectedAmount = amt),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Frequency selection
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('One-time'),
                              value: 'One-time',
                              groupValue: _frequency,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primaryContainer,
                              onChanged: (val) => setState(() => _frequency = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Monthly'),
                              value: 'Monthly',
                              groupValue: _frequency,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primaryContainer,
                              onChanged: (val) => setState(() => _frequency = val!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Next Button
                DignityButton(
                  text: 'Proceed to Payment Methods (Step 2)',
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    context.push(
                      '/donations-step2?amount=$_selectedAmount&kit=$_kitPercent&dev=$_devPercent&freq=$_frequency',
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
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
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildMetric(String val, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softLavender,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryContainer, size: 20),
        ),
        const SizedBox(height: 4),
        Text(val, style: AppTypography.labelLG(color: AppColors.neutralDark)),
        Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
      ],
    );
  }

  Widget _buildSplitBtn(String text, int kit, int dev) {
    final isSelected = _kitPercent == kit && _devPercent == dev;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
        foregroundColor: isSelected ? Colors.white : AppColors.primaryContainer,
        side: BorderSide(
          color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullBorder),
      ),
      onPressed: () => _setSplit(kit, dev),
      child: Text(text, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.primaryContainer)),
    );
  }
}
