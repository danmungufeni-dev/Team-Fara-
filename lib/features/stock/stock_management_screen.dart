import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/stock_item.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_text_field.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final MockBackendStore _store = MockBackendStore();
  final _intakeQtyController = TextEditingController();
  final _batchController = TextEditingController();
  String _selectedItemName = 'Regular Flow Day Pads (Wings)';

  void _adjustStock(String id, int delta) {
    setState(() {
      final idx = _store.stockItems.indexWhere((s) => s.id == id);
      if (idx >= 0) {
        final current = _store.stockItems[idx];
        final newCount = (current.count + delta).clamp(0, current.capacity);
        _store.stockItems[idx] = current.copyWith(count: newCount);
      }
    });
  }

  void _setStatus(String id, StockStatus status) {
    setState(() {
      final idx = _store.stockItems.indexWhere((s) => s.id == id);
      if (idx >= 0) {
        _store.stockItems[idx] = _store.stockItems[idx].copyWith(status: status);
      }
    });
  }

  void _recordIntake() {
    final qty = int.tryParse(_intakeQtyController.text) ?? 20;
    setState(() {
      final idx = _store.stockItems.indexWhere(
        (s) => s.name.toLowerCase().contains(_selectedItemName.toLowerCase()),
      );
      if (idx >= 0) {
        final item = _store.stockItems[idx];
        _store.stockItems[idx] = item.copyWith(count: item.count + qty);
      }
      _intakeQtyController.clear();
      _batchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged intake of $qty packs for $_selectedItemName.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void dispose() {
    _intakeQtyController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockItems = _store.stockItems;
    final totalAvailable = stockItems.fold<int>(0, (sum, i) => sum + i.count);

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
            Text('Stock Management', style: AppTypography.headlineSM()),
            Text('Counter 3: Main Dispensary • Kisenyi',
                style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync with MOH Central Ledger',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock count synchronized with Central Grid.')),
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
                // Overview Capacity Card
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dispensary Hub Quota', style: AppTypography.labelLG()),
                          const DignityBadge(text: 'Optimal Level (82%)', variant: DignityBadgeVariant.success),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat('$totalAvailable', 'Total In-Stock', AppColors.success),
                          _buildSummaryStat('14', 'Held Vouchers', AppColors.primaryContainer),
                          _buildSummaryStat('24', 'Given Today', AppColors.coralPink),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Dignity Supplies In Stock
                Text('Dignity Supplies In Stock', style: AppTypography.labelLG()),
                const SizedBox(height: 10),

                ...stockItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DignityCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(item.name, style: AppTypography.labelLG(color: AppColors.neutralDark)),
                              ),
                              Text('${item.count} / ${item.capacity}', style: AppTypography.headlineSM(color: AppColors.primaryContainer)),
                            ],
                          ),
                          Text(item.description, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
                          const SizedBox(height: 8),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (item.count / item.capacity).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                item.count < 15 ? AppColors.coralPink : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Quick Adjustment Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAdjustBtn('-5', () => _adjustStock(item.id, -5)),
                              _buildAdjustBtn('-1', () => _adjustStock(item.id, -1)),
                              _buildAdjustBtn('+1', () => _adjustStock(item.id, 1)),
                              _buildAdjustBtn('+10', () => _adjustStock(item.id, 10)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Status Toggles
                          Row(
                            children: [
                              _buildStatusChip(item, StockStatus.available, 'Available'),
                              const SizedBox(width: 6),
                              _buildStatusChip(item, StockStatus.limited, 'Limited'),
                              const SizedBox(width: 6),
                              _buildStatusChip(item, StockStatus.outOfStock, 'Out of Stock'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Record Incoming Supply / NGO Intake Form
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_box, color: AppColors.primaryContainer),
                          const SizedBox(width: 8),
                          Text('Record Incoming Supply / NGO Intake', style: AppTypography.labelLG()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedItemName,
                        decoration: InputDecoration(
                          labelText: 'Select Product',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                        ),
                        items: stockItems.map((s) {
                          return DropdownMenuItem(value: s.name, child: Text(s.name));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedItemName = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DignityTextField(
                        controller: _intakeQtyController,
                        label: 'Received Quantity (Packs)',
                        hintText: 'e.g. 50',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DignityTextField(
                        controller: _batchController,
                        label: 'NGO Source / MoH Delivery Note #',
                        hintText: 'e.g. AFRIpads-NGO-KLA-992',
                      ),
                      const SizedBox(height: 16),
                      DignityButton(
                        text: 'Record Batch Intake',
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: _recordIntake,
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

  Widget _buildSummaryStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: AppTypography.headlineSM(color: color)),
        Text(label, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
      ],
    );
  }

  Widget _buildAdjustBtn(String label, VoidCallback onTap) {
    return SizedBox(
      height: 34,
      width: 60,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        onPressed: onTap,
        child: Text(label, style: AppTypography.labelSM(color: AppColors.primaryContainer)),
      ),
    );
  }

  Widget _buildStatusChip(StockItem item, StockStatus status, String label) {
    final isSelected = item.status == status;
    return InkWell(
      onTap: () => _setStatus(item.id, status),
      borderRadius: AppRadius.fullBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: AppRadius.fullBorder,
        ),
        child: Text(
          label,
          style: AppTypography.labelSM(color: isSelected ? Colors.white : AppColors.neutralDark),
        ),
      ),
    );
  }
}
