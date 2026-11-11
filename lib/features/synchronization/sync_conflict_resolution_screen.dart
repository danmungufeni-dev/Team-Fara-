import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/conflict_model.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class SyncConflictResolutionScreen extends StatefulWidget {
  const SyncConflictResolutionScreen({super.key});

  @override
  State<SyncConflictResolutionScreen> createState() =>
      _SyncConflictResolutionScreenState();
}

class _SyncConflictResolutionScreenState
    extends State<SyncConflictResolutionScreen> {
  final MockBackendStore _store = MockBackendStore();
  late SyncConflict _conflict;

  @override
  void initState() {
    super.initState();
    _conflict = _store.activeConflict;
  }

  void _applyStrategy(ResolutionStrategy strategy) {
    setState(() {
      final updatedAttributes = _conflict.attributes.map((attr) {
        String val;
        switch (strategy) {
          case ResolutionStrategy.keepLocal:
            val = attr.localValue;
            break;
          case ResolutionStrategy.acceptRemote:
            val = attr.remoteValue;
            break;
          case ResolutionStrategy.smartMerge:
            val = attr.localValue; // Prefer fresh local intake
            break;
        }
        return attr.copyWith(selectedValue: val);
      }).toList();

      _conflict = _conflict.copyWith(
        activeStrategy: strategy,
        attributes: updatedAttributes,
      );
    });
  }

  void _selectFieldValue(int index, String val) {
    setState(() {
      final attrs = List<ConflictAttribute>.from(_conflict.attributes);
      attrs[index] = attrs[index].copyWith(selectedValue: val);
      _conflict = _conflict.copyWith(attributes: attrs);
    });
  }

  void _commitResolution() {
    setState(() {
      _conflict = _conflict.copyWith(isResolved: true);
      _store.activeConflict = _conflict;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CRDT Commit signed and merged into Central Ledger!'),
        backgroundColor: AppColors.success,
      ),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.pop();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conflict Resolution', style: AppTypography.headlineSM()),
            Text('Resolve Concurrent Field Edits',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CRDT engine merges conflict-free replicated data types automatically.'),
                ),
              );
            },
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
                // Conflict Entity Header
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync_problem, color: AppColors.coralPink),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _conflict.hubName,
                              style: AppTypography.headlineSM(color: AppColors.neutralDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Remote: ${_conflict.remoteUser} • 11:24 AM', style: AppTypography.bodySM()),
                      Text('Local: ${_conflict.localUser} • 11:40 AM (+16m ahead)', style: AppTypography.bodySM(color: AppColors.primaryContainer)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Strategy Presets
                Text('Quick Strategy Preset', style: AppTypography.labelLG()),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStrategyBtn(
                        ResolutionStrategy.smartMerge,
                        'Smart Merge',
                        'Balanced CRDT',
                        Icons.auto_fix_high,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStrategyBtn(
                        ResolutionStrategy.keepLocal,
                        'Keep Local',
                        'Force Outpost',
                        Icons.phonelink_setup,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStrategyBtn(
                        ResolutionStrategy.acceptRemote,
                        'Accept Remote',
                        'Server Wins',
                        Icons.cloud_done,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Conflicting Attributes
                Text('Conflicting Attributes (3)', style: AppTypography.labelLG()),
                const SizedBox(height: 10),

                ..._conflict.attributes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attr = entry.value;

                  final isLocalChosen = attr.selectedValue == attr.localValue;
                  final isRemoteChosen = attr.selectedValue == attr.remoteValue;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DignityCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(attr.label, style: AppTypography.labelMD(color: AppColors.neutralDark)),
                          const SizedBox(height: 10),

                          // Local Option
                          InkWell(
                            onTap: () => _selectFieldValue(index, attr.localValue),
                            borderRadius: AppRadius.mdBorder,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isLocalChosen ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(
                                  color: isLocalChosen ? AppColors.primaryContainer : AppColors.borderSubtle,
                                  width: isLocalChosen ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isLocalChosen ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: isLocalChosen ? AppColors.primaryContainer : AppColors.neutralMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Local Field Version', style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                                        Text(attr.localValue, style: AppTypography.bodyMD()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Remote Option
                          InkWell(
                            onTap: () => _selectFieldValue(index, attr.remoteValue),
                            borderRadius: AppRadius.mdBorder,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isRemoteChosen ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(
                                  color: isRemoteChosen ? AppColors.primaryContainer : AppColors.borderSubtle,
                                  width: isRemoteChosen ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isRemoteChosen ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: isRemoteChosen ? AppColors.primaryContainer : AppColors.neutralMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Remote Server Version', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                                        Text(attr.remoteValue, style: AppTypography.bodyMD()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // 5 Fields Auto-Reconciled Safely note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCF8EC),
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '5 Non-Conflicting Attributes Auto-Reconciled Safely (Facility Name, GPS Coordinates, MoH License, Discretion Protocol, Clean Water).',
                          style: AppTypography.labelSM(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Finalize Action
                DignityButton(
                  text: 'Finalize & Sign CRDT Commit',
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  onPressed: _commitResolution,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyBtn(
    ResolutionStrategy strategy,
    String title,
    String sub,
    IconData icon,
  ) {
    final isSelected = _conflict.activeStrategy == strategy;
    return InkWell(
      onTap: () => _applyStrategy(strategy),
      borderRadius: AppRadius.mdBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.primaryContainer),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.labelSM(color: isSelected ? Colors.white : AppColors.neutralDark),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.neutralMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
