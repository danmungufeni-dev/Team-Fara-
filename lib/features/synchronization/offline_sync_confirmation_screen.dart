import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class OfflineSyncConfirmationScreen extends StatelessWidget {
  final String queueId;
  final String payloadSize;
  final String localHash;

  const OfflineSyncConfirmationScreen({
    super.key,
    this.queueId = '#OFFLINE-SYNC-9842',
    this.payloadSize = '2.4 MB Cached',
    this.localHash = 'e8f2...7c1a',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Transmission Protocol', style: AppTypography.headlineSM()),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.softLavender,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_done, size: 40, color: AppColors.primaryContainer),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Saved Locally to Secure Queue',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSM(color: AppColors.neutralDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '2G / Edge Mesh Outpost Protocol Active',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.primaryContainer),
                ),
                const SizedBox(height: 24),

                // Receipt Breakdown Card
                DignityCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Queue Identifier', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                          Row(
                            children: [
                              Text(queueId, style: AppTypography.labelMD(color: AppColors.neutralDark)),
                              IconButton(
                                icon: const Icon(Icons.content_copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: queueId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Queue ID copied to clipboard!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      _buildRow('Payload Size', payloadSize),
                      const Divider(color: AppColors.borderSubtle),
                      _buildRow('Attached Media', '2 Geo-Photos Cached'),
                      const Divider(color: AppColors.borderSubtle),
                      _buildRow('Cryptographic Hash', localHash),
                      const Divider(color: AppColors.borderSubtle),
                      _buildRow('Queue Position', '1 of 3 pending field dispatches'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Informational Card
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings_input_antenna, color: AppColors.primaryContainer),
                          const SizedBox(width: 8),
                          Text('Automatic Edge Broadcasting', style: AppTypography.labelMD()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This record is encrypted and saved in your device storage. As soon as you enter cell range or connect to a local peer mesh, it will transmit automatically to the Central Grid.',
                        style: AppTypography.bodySM(color: AppColors.neutralMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                DignityButton(
                  text: 'View Offline Sync Queue',
                  icon: const Icon(Icons.sync, color: Colors.white),
                  onPressed: () => context.push('/sync'),
                ),
                const SizedBox(height: 12),
                DignityButton(
                  text: 'Emergency SMS Dispatch (Free USSD)',
                  style: DignityButtonStyle.outline,
                  icon: const Icon(Icons.sms, color: AppColors.primaryContainer),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Encoded compressed packet sent via free USSD transport.')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                DignityButton(
                  text: 'Return to Dashboard',
                  style: DignityButtonStyle.secondary,
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          Text(value, style: AppTypography.labelMD(color: AppColors.neutralDark)),
        ],
      ),
    );
  }
}
