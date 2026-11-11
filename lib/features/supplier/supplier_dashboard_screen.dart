import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  final TextEditingController _pinController = TextEditingController();
  int _todayDisbursed = 24;
  String? _verificationResult;

  void _verifyPin() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    if (pin.contains('749') || pin.toUpperCase().contains('PAD')) {
      setState(() {
        _todayDisbursed++;
        _verificationResult =
            '✅ Verified Voucher $pin: 1x Regular Wings (10s) + 1x Reusable Kit. Handed over to seeker in opaque kraft bag.';
        _pinController.clear();
      });
    } else {
      setState(() {
        _verificationResult =
            '⚠️ Token code not found in current clinic allocation queue. Please verify digits.';
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
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
            Text('Supplier Dashboard', style: AppTypography.headlineSM()),
            Text('Kisenyi Health Center IV • Counter 3',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
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
                // Welcome Banner
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.softLavender,
                            child: Icon(Icons.person, color: AppColors.primaryContainer),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome back, Harriet', style: AppTypography.headlineSM()),
                                Text('On-Duty Caretaker & Dispensary Matron', style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: const [
                          DignityBadge(text: 'Counter Active', variant: DignityBadgeVariant.success, icon: Icon(Icons.meeting_room, size: 14, color: AppColors.success)),
                          DignityBadge(text: 'Open • Receiving', variant: DignityBadgeVariant.verified),
                          DignityBadge(text: 'Verified 18m ago', variant: DignityBadgeVariant.neutral),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Seeker PIN Redemption Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pin, color: AppColors.primaryContainer),
                          const SizedBox(width: 8),
                          Text('Enter Seeker Pickup PIN', style: AppTypography.labelLG()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pinController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'e.g. 749 or PAD-749',
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.mdBorder,
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          DignityButton(
                            text: 'Verify',
                            width: 90,
                            onPressed: _verifyPin,
                          ),
                        ],
                      ),
                      if (_verificationResult != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _verificationResult!.startsWith('✅')
                                ? const Color(0xFFDCF8EC)
                                : AppColors.errorContainer,
                            borderRadius: AppRadius.mdBorder,
                          ),
                          child: Text(
                            _verificationResult!,
                            style: AppTypography.labelSM(
                              color: _verificationResult!.startsWith('✅')
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Available Stock', '107 packs', Icons.inventory_2, AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Ready Pickups', '14 pending', Icons.shopping_bag, AppColors.primaryContainer)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Disbursed Today', '$_todayDisbursed units', Icons.check_circle, AppColors.coralPink)),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Navigation to Stock Management
                DignityCard(
                  onTap: () => context.push('/stock'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.softLavender,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: const Icon(Icons.add_box, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stock Management & NGO Intake', style: AppTypography.labelLG()),
                            Text('Update inventory counters, mark supplies limited/out of stock', style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutralMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Hourly Pickup Heatmap Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hourly Pickup Heatmap', style: AppTypography.labelLG()),
                      const SizedBox(height: 4),
                      Text('Peak collection safe hours at Counter 3', style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBar('9 AM', 0.3),
                            _buildBar('11 AM', 0.6),
                            _buildBar('1 PM', 0.9, isPeak: true),
                            _buildBar('3 PM', 0.7),
                            _buildBar('5 PM', 0.4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Distribution Log
                Text('Recent Distribution Log', style: AppTypography.labelLG()),
                const SizedBox(height: 8),
                _buildLogTile('#PAD-749', '1x Regular Wings + 1x Reusable Kit', '12:14 PM', 'Disbursed'),
                _buildLogTile('#PAD-742', '2x Heavy Overnight Packs', '11:45 AM', 'Disbursed'),
                _buildLogTile('#PAD-738', '1x Reusable AFRIpads Kit', '10:30 AM', 'Disbursed'),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(val, style: AppTypography.labelLG(color: AppColors.neutralDark)),
          Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
        ],
      ),
    );
  }

  Widget _buildBar(String time, double heightFraction, {bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 70 * heightFraction,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.coralPink : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: AppTypography.labelSM()),
      ],
    );
  }

  Widget _buildLogTile(String token, String items, String time, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$token • $items', style: AppTypography.labelMD()),
                  Text(time, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                ],
              ),
            ),
            DignityBadge(text: status, variant: DignityBadgeVariant.success),
          ],
        ),
      ),
    );
  }
}
