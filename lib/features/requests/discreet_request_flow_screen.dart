import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/request_voucher.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class DiscreetRequestFlowScreen extends StatefulWidget {
  const DiscreetRequestFlowScreen({super.key});

  @override
  State<DiscreetRequestFlowScreen> createState() =>
      _DiscreetRequestFlowScreenState();
}

class _DiscreetRequestFlowScreenState extends State<DiscreetRequestFlowScreen> {
  final MockBackendStore _store = MockBackendStore();
  String _pickupWindow = 'Within the next 2 hours';
  bool _isLocked = false;

  final List<Map<String, String>> _windows = const [
    {
      'title': 'Within the next 2 hours',
      'tag': 'Fast',
      'desc': 'Recommended • Pre-packed priority bag ready at Counter 3',
    },
    {
      'title': 'Today before 5:00 PM',
      'tag': 'Same Day',
      'desc': 'Held under your token until clinic close',
    },
    {
      'title': 'Tomorrow Morning',
      'tag': 'Next Day',
      'desc': 'Held in secure overnight dispensary locker',
    },
  ];

  void _confirmReservation() {
    setState(() => _isLocked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Confidential Voucher PAD-749 locked successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.push('/messaging');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final voucher = _store.vouchers.isNotEmpty
        ? _store.vouchers.first
        : RequestVoucher(
            id: 'v_fallback',
            voucherCode: 'PAD-749',
            hubId: 'hub_kisenyi',
            hubName: 'Kisenyi Health Center IV',
            allocationSummary:
                '1x Regular Winged Pack (10 pads) + 1x Reusable Kit',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 3)),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Discreet Request', style: AppTypography.headlineSM()),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Direct Discreet Chat',
            onPressed: () => context.push('/messaging'),
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
                // Hub Identification Card
                DignityCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.softLavender,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: const Icon(Icons.local_hospital,
                            color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dispensing Point',
                                style: AppTypography.labelSM(
                                    color: AppColors.neutralMuted)),
                            Text(voucher.hubName,
                                style: AppTypography.labelLG(
                                    color: AppColors.neutralDark)),
                            Text('850m away • Closes 5:00 PM',
                                style: AppTypography.bodySM(
                                    color: AppColors.success)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Allocation Details
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reserved Allocation',
                              style: AppTypography.labelLG()),
                          const DignityBadge(
                            text: '100% Free Aid',
                            variant: DignityBadgeVariant.verified,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2,
                              color: AppColors.primaryContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              voucher.allocationSummary,
                              style: AppTypography.bodyMD(
                                  color: AppColors.neutralDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Confidential Pickup Code Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF58236A), Color(0xFF713B83)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.cardBorder,
                    boxShadow: AppElevation.level3,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'CONFIDENTIAL PICKUP CODE',
                            style: AppTypography.labelSM(color: Colors.white70)
                                .copyWith(letterSpacing: 1.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            voucher.voucherCode,
                            style: AppTypography.headlineXL(color: Colors.white)
                                .copyWith(
                              letterSpacing: 4.0,
                              fontSize: 38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.content_copy,
                                color: Colors.white),
                            tooltip: 'Copy Code',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: voucher.voucherCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voucher code copied!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barcode simulation
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            28,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 1),
                              height: 36,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Your name is NEVER displayed on the package. Center staff will only verify this 6-character code.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySM(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pickup Window Selection
                Text('Select Pickup Window', style: AppTypography.labelLG()),
                const SizedBox(height: 10),
                ..._windows.map((w) {
                  final isSelected = _pickupWindow == w['title'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => setState(() => _pickupWindow = w['title']!),
                      borderRadius: AppRadius.cardBorder,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surfaceContainerLow
                              : AppColors.surfaceContainerLowest,
                          borderRadius: AppRadius.cardBorder,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.borderSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: w['title']!,
                              groupValue: _pickupWindow,
                              activeColor: AppColors.primaryContainer,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _pickupWindow = val);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(w['title']!,
                                          style: AppTypography.labelMD(
                                              color: AppColors.neutralDark)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.softLavender,
                                          borderRadius: AppRadius.fullBorder,
                                        ),
                                        child: Text(w['tag']!,
                                            style: AppTypography.labelSM(
                                                color:
                                                    AppColors.primaryContainer)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(w['desc']!,
                                      style: AppTypography.bodySM(
                                          color: AppColors.neutralMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Lock Reservation Button
                DignityButton(
                  text: _isLocked
                      ? 'Voucher Locked • Open Chat'
                      : 'Confirm & Lock Reservation',
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  onPressed: _confirmReservation,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (idx) {
          switch (idx) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.push('/map');
              break;
            case 2:
              break;
            case 3:
              context.push('/donations');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }
}
