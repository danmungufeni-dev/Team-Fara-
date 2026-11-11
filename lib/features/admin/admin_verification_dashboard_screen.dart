import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class AdminVerificationDashboardScreen extends StatefulWidget {
  const AdminVerificationDashboardScreen({super.key});

  @override
  State<AdminVerificationDashboardScreen> createState() =>
      _AdminVerificationDashboardScreenState();
}

class _AdminVerificationDashboardScreenState
    extends State<AdminVerificationDashboardScreen> {
  final List<Map<String, dynamic>> _queue = [
    {
      'id': 'q_1',
      'name': 'Kawempe Youth Hope Sanctuary',
      'category': 'Youth Sanctuary',
      'division': 'Kawempe Division',
      'license': 'MOH-KLA-2024-9912',
      'caretaker': 'Sister Florence N.',
      'status': 'Pending Verification',
    },
    {
      'id': 'q_2',
      'name': 'St. Jude Secondary School',
      'category': 'School Safe Space',
      'division': 'Nakawa Division',
      'license': 'MOES-UG-2024-4410',
      'caretaker': 'Matron Christine A.',
      'status': 'Pending Verification',
    },
  ];

  int _stockThreshold = 25;
  String _selectedRoleMatrix = 'SuperAdmin (HQ)';

  void _approveHub(int index) {
    setState(() {
      final item = _queue.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approved ${item['name']}! Added to Central Grid.'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  void _rejectHub(int index) {
    setState(() {
      final item = _queue.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flagged ${item['name']} for additional dignity inspection.'),
          backgroundColor: AppColors.error,
        ),
      );
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
            Text('Admin Verification HQ', style: AppTypography.headlineSM()),
            Text('Central Kampala Grid • v3.4.1 Live',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Offline Queue',
            onPressed: () => context.push('/sync'),
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
                // Network Overview Stats
                Row(
                  children: [
                    Expanded(child: _buildMetricBox('3,840', 'Active Seekers', '+412 wk', Icons.groups)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricBox('42', 'Verified Hubs', '${_queue.length} review', Icons.storefront)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMetricBox('10,420', 'Disbursed (Mo)', 'UGX 0 cost', Icons.inventory_2)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricBox('99.8%', 'Data Freshness', 'Live sync', Icons.cell_tower)),
                  ],
                ),
                const SizedBox(height: 18),

                // Verification Queue Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Verification Queue (${_queue.length})', style: AppTypography.labelLG()),
                    Text('Field Audits', style: AppTypography.labelSM(color: AppColors.primaryContainer)),
                  ],
                ),
                const SizedBox(height: 10),

                if (_queue.isEmpty)
                  DignityCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('All pending hubs verified. Queue is clear!', style: AppTypography.bodyMD(color: AppColors.success)),
                      ),
                    ),
                  )
                else
                  ..._queue.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hub = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DignityCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(hub['name'], style: AppTypography.labelLG(color: AppColors.neutralDark)),
                                DignityBadge(text: hub['status'], variant: DignityBadgeVariant.neutral),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${hub['category']} • ${hub['division']}', style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                            Text('License: ${hub['license']} • Caretaker: ${hub['caretaker']}', style: AppTypography.bodySM()),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DignityButton(
                                    text: 'Approve Hub',
                                    height: 38,
                                    icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                    onPressed: () => _approveHub(index),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DignityButton(
                                    text: 'Audit Protocol',
                                    height: 38,
                                    style: DignityButtonStyle.outline,
                                    icon: const Icon(Icons.security, size: 16, color: AppColors.primaryContainer),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Dignity Protocol checklist passed inspection.')),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.error),
                                  onPressed: () => _rejectHub(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),

                // Role-Based Notification Routing Matrix
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role-Based Notification Routing', style: AppTypography.labelLG()),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildRoleChip('SuperAdmin (HQ)'),
                          const SizedBox(width: 8),
                          _buildRoleChip('Field Caretakers (Hubs)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Low Stock Alert Threshold (%)', style: AppTypography.labelMD()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryContainer),
                            onPressed: () => setState(() => _stockThreshold = (_stockThreshold - 5).clamp(10, 50)),
                          ),
                          Text('$_stockThreshold% Remaining Quota', style: AppTypography.labelLG()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryContainer),
                            onPressed: () => setState(() => _stockThreshold = (_stockThreshold + 5).clamp(10, 50)),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildMetricBox(String val, String title, String sub, IconData icon) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val, style: AppTypography.headlineSM(color: AppColors.primaryContainer)),
              Icon(icon, color: AppColors.primaryContainer, size: 20),
            ],
          ),
          const SizedBox(height: 2),
          Text(title, style: AppTypography.labelSM(color: AppColors.neutralDark)),
          Text(sub, style: AppTypography.labelSM(color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    final isSelected = _selectedRoleMatrix == role;
    return ChoiceChip(
      label: Text(role),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.neutralDark),
      onSelected: (_) => setState(() => _selectedRoleMatrix = role),
    );
  }
}
