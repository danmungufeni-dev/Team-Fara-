import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/offline_sync_item.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class FullOfflineQueueSyncScreen extends StatefulWidget {
  const FullOfflineQueueSyncScreen({super.key});

  @override
  State<FullOfflineQueueSyncScreen> createState() =>
      _FullOfflineQueueSyncScreenState();
}

class _FullOfflineQueueSyncScreenState
    extends State<FullOfflineQueueSyncScreen> {
  final MockBackendStore _store = MockBackendStore();
  bool _isSyncing = false;
  bool _meshListenerOn = true;
  bool _adaptiveCompression = true;

  void _syncAll() {
    setState(() => _isSyncing = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _store.offlineQueue = _store.offlineQueue
              .map((item) => item.copyWith(status: SyncItemStatus.synced))
              .toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All pending items successfully synchronized via CRDT engine!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = _store.offlineQueue;
    final pendingCount =
        queue.where((i) => i.status == SyncItemStatus.pending).length;

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
            Text('Offline Queue & Sync', style: AppTypography.headlineSM()),
            Text('2G / Edge Mesh Outpost',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryContainer,
                    ),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Trigger Sync',
            onPressed: _isSyncing ? null : _syncAll,
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
                // Diagnostics Header Banner
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cell_tower, color: AppColors.primaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text('Kampala North Outpost', style: AppTypography.labelLG()),
                          const Spacer(),
                          Text('RSSI: -94 dBm', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sync Daemon: Active • Mesh Listener: ${_meshListenerOn ? "ON" : "OFF"}',
                        style: AppTypography.labelSM(color: AppColors.success),
                      ),
                      const SizedBox(height: 14),
                      DignityButton(
                        text: _isSyncing
                            ? 'Syncing Micro-Packets...'
                            : 'Sync All Pending ($pendingCount Items)',
                        isLoading: _isSyncing,
                        icon: const Icon(Icons.cloud_upload, color: Colors.white),
                        onPressed: _isSyncing || pendingCount == 0 ? null : _syncAll,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Field Transmission Rules
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Field Transmission Rules', style: AppTypography.labelLG()),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: _adaptiveCompression,
                        activeThumbColor: AppColors.primaryContainer,
                        title: const Text('Adaptive Micro-Packets (80% compression)'),
                        subtitle: const Text('Defers large EXIF image payloads until high-bandwidth Wi-Fi.'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _adaptiveCompression = val),
                      ),
                      const Divider(color: AppColors.borderSubtle),
                      SwitchListTile(
                        value: _meshListenerOn,
                        activeThumbColor: AppColors.primaryContainer,
                        title: const Text('Sync Over 2G / 3G Cellular'),
                        subtitle: const Text('Permit slow-network field queue updates.'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _meshListenerOn = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Conflict Banner Link
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  onTap: () => context.push('/sync-conflict'),
                  child: Row(
                    children: [
                      const Icon(Icons.difference, color: AppColors.primaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CRDT 3-Way Diff Audit', style: AppTypography.labelLG()),
                            Text('1 Concurrent field conflict detected on Hub #MOH-KLA-2024-8849', style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primaryContainer),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Queue Items List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Field Queue Items (${queue.length})', style: AppTypography.labelLG()),
                    Text('Priority FIFO', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                  ],
                ),
                const SizedBox(height: 10),

                ...queue.map((item) {
                  final isSynced = item.status == SyncItemStatus.synced;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DignityCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSynced
                                  ? const Color(0xFFDCF8EC)
                                  : AppColors.softLavender,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSynced ? Icons.cloud_done : Icons.cloud_queue,
                              color: isSynced ? AppColors.success : AppColors.primaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.title, style: AppTypography.labelMD(color: AppColors.neutralDark)),
                                    ),
                                    Text(item.queueIdentifier, style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(item.description, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                                const SizedBox(height: 4),
                                Text(
                                  'Size: ${(item.payloadSizeBytes / 1024).toStringAsFixed(0)} KB • Hash: ${item.localHash}',
                                  style: AppTypography.labelSM(color: AppColors.neutralMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
