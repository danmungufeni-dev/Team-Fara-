import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/distribution_point.dart';
import '../../data/models/offline_sync_item.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_chip.dart';
import '../../shared/widgets/dignity_text_field.dart';

class AddDistributionPointScreen extends StatefulWidget {
  const AddDistributionPointScreen({super.key});

  @override
  State<AddDistributionPointScreen> createState() =>
      _AddDistributionPointScreenState();
}

class _AddDistributionPointScreenState
    extends State<AddDistributionPointScreen> {
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCategory = 'Clinic / Primary Unit';
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};

  int _regularWings = 50;
  int _heavyNight = 30;
  int _reusableKits = 15;

  bool _hasPrivateRoom = true;
  bool _hasFemaleStaff = true;
  bool _hasWheelchairAccess = true;

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(bool isOffline) {
    final store = MockBackendStore();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Kasubi Safe-Space Sanctuary';

    final newPoint = DistributionPoint(
      id: 'hub_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _selectedCategory,
      distanceMeters: 1200,
      walkingTimeMinutes: 16,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : 'Kasubi Ring Road, Kampala',
      latitude: 0.3312,
      longitude: 32.5524,
      isVerified: true,
      openHours: 'Open • Closes 5:30 PM',
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : '+256 700 112 334',
      stockDayPads: _regularWings,
      stockOvernightPads: _heavyNight,
      stockReusableKits: _reusableKits,
      hasFemaleCaretaker: _hasFemaleStaff,
      hasPrivateCubicle: _hasPrivateRoom,
      hasWheelchairRamp: _hasWheelchairAccess,
    );

    store.hubs.insert(0, newPoint);

    if (isOffline) {
      final syncItem = OfflineSyncItem(
        id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
        queueIdentifier: '#OFFLINE-SYNC-${2000 + store.offlineQueue.length}',
        type: SyncItemType.hubRegistration,
        title: 'Hub Registration: $name',
        description: 'New verified sanctuary queued for edge mesh dispatch.',
        payload: newPoint.toJson(),
        payloadSizeBytes: 2457600,
        attachedMediaCount: 2,
        localHash: 'e8f2...7c1a',
        queuePosition: store.offlineQueue.length + 1,
        createdAt: DateTime.now(),
      );
      store.offlineQueue.insert(0, syncItem);
      context.push('/offline-sync-confirmation');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Distribution Point registered successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
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
        title: Text('Add Distribution Point', style: AppTypography.headlineSM()),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
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
                // Top Progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.mdBorder,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, color: AppColors.primaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        'Step 1 of 3: Facility & Dignity Audit',
                        style: AppTypography.labelMD(color: AppColors.primaryContainer),
                      ),
                      const Spacer(),
                      Text('85% Ready', style: AppTypography.labelSM(color: AppColors.success)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // General Information Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('General Information', style: AppTypography.labelLG()),
                      const SizedBox(height: 12),
                      DignityTextField(
                        controller: _nameController,
                        label: 'Hub or Partner Organization Name',
                        hintText: 'e.g. Kasubi Safe-Space Sanctuary',
                        prefixIcon: const Icon(Icons.apartment, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 14),
                      Text('Sanctuary / Facility Category', style: AppTypography.labelMD()),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCatChip('Clinic / Primary Unit', Icons.local_hospital),
                          _buildCatChip('Youth Safe Space', Icons.diversity_1),
                          _buildCatChip('School Sanctuary', Icons.school),
                          _buildCatChip('CBO Outreach', Icons.volunteer_activism),
                          _buildCatChip('Faith Community', Icons.church),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DignityTextField(
                        controller: _licenseController,
                        label: 'Partner Reg / MoH License No.',
                        hintText: 'MOH-KLA-2024-XXXX',
                        prefixIcon: const Icon(Icons.verified, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 14),
                      DignityTextField(
                        controller: _addressController,
                        label: 'Physical Address / Landmark',
                        hintText: 'Plot 4 Kasubi Ring Road, Opposite Market',
                        prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(height: 14),
                      DignityTextField(
                        controller: _phoneController,
                        label: 'Direct Confidential Desk Phone',
                        hintText: '+256 700 000 000',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone, color: AppColors.primaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Schedule & Allocation Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Operating Days & Dignity Quota', style: AppTypography.labelLG()),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _days.map((d) {
                          final selected = _selectedDays.contains(d);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedDays.remove(d);
                                } else {
                                  _selectedDays.add(d);
                                }
                              });
                            },
                            borderRadius: AppRadius.fullBorder,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: selected
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh,
                              child: Text(
                                d,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.neutralDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Initial Stock In-Take', style: AppTypography.labelMD()),
                      const SizedBox(height: 8),
                      _buildCounterRow('Regular Wings (10s)', _regularWings, (v) => setState(() => _regularWings = v)),
                      _buildCounterRow('Heavy Night (8s)', _heavyNight, (v) => setState(() => _heavyNight = v)),
                      _buildCounterRow('Reusable AFRIpads', _reusableKits, (v) => setState(() => _reusableKits = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Discretion Protocol Checklist
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dignity & Discretion Checklist', style: AppTypography.labelLG()),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _hasPrivateRoom,
                        activeColor: AppColors.primaryContainer,
                        title: const Text('Private dispensing cubicle with separate exit'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _hasPrivateRoom = val ?? true),
                      ),
                      CheckboxListTile(
                        value: _hasFemaleStaff,
                        activeColor: AppColors.primaryContainer,
                        title: const Text('Female nurse or caretaker on duty during open hours'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _hasFemaleStaff = val ?? true),
                      ),
                      CheckboxListTile(
                        value: _hasWheelchairAccess,
                        activeColor: AppColors.primaryContainer,
                        title: const Text('Wheelchair ramp and accessible walkway'),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _hasWheelchairAccess = val ?? true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submission Buttons
                DignityButton(
                  text: 'Submit & Register Hub',
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () => _submit(false),
                ),
                const SizedBox(height: 12),
                DignityButton(
                  text: 'Queue Offline (Field Outpost)',
                  style: DignityButtonStyle.secondary,
                  icon: const Icon(Icons.cloud_off, color: AppColors.primaryContainer),
                  onPressed: () => _submit(true),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatChip(String label, IconData icon) {
    final selected = _selectedCategory == label;
    return DignityChip(
      label: label,
      leading: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primaryContainer),
      isSelected: selected,
      onTap: () => setState(() => _selectedCategory = label),
    );
  }

  Widget _buildCounterRow(String label, int count, ValueChanged<int> onUpdate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMD()),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryContainer),
                onPressed: count > 0 ? () => onUpdate(count - 5) : null,
              ),
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text('$count', style: AppTypography.labelLG()),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryContainer),
                onPressed: () => onUpdate(count + 5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
