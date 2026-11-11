import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';

class DistributionPointDetailsScreen extends StatefulWidget {
  final String hubId;

  const DistributionPointDetailsScreen({super.key, required this.hubId});

  @override
  State<DistributionPointDetailsScreen> createState() =>
      _DistributionPointDetailsScreenState();
}

class _DistributionPointDetailsScreenState
    extends State<DistributionPointDetailsScreen> {
  final MockBackendStore _store = MockBackendStore();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = _store.currentUser.savedHubIds.contains(widget.hubId);
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      final list = List<String>.from(_store.currentUser.savedHubIds);
      if (_isBookmarked) {
        list.add(widget.hubId);
      } else {
        list.remove(widget.hubId);
      }
      _store.currentUser = _store.currentUser.copyWith(savedHubIds: list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hub = _store.hubs.firstWhere(
      (h) => h.id == widget.hubId,
      orElse: () => _store.hubs.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Distribution Hub', style: AppTypography.headlineSM()),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.primaryContainer : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hub link copied to clipboard discreetly.'),
                  behavior: SnackBarBehavior.floating,
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
                // Top Header Card
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const DignityBadge(
                            text: 'MOH Verified',
                            variant: DignityBadgeVariant.verified,
                            icon: Icon(Icons.verified, size: 14, color: AppColors.success),
                          ),
                          const SizedBox(width: 8),
                          DignityBadge(
                            text: hub.category,
                            variant: DignityBadgeVariant.neutral,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Color(0xFFF4B400)),
                              const SizedBox(width: 4),
                              Text('${hub.rating}', style: AppTypography.labelMD()),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(hub.name, style: AppTypography.headlineSM(color: AppColors.neutralDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.primaryContainer),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hub.address,
                              style: AppTypography.bodySM(color: AppColors.neutralMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Pedestrian distance & Safe Route banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_walk, color: AppColors.primaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${hub.distanceMeters.toInt()}m away • ${hub.walkingTimeMinutes} mins walk',
                                    style: AppTypography.labelMD(color: AppColors.neutralDark),
                                  ),
                                  Text(
                                    'Safe Pedestrian Route Active • Well-lit public street',
                                    style: AppTypography.labelSM(color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionBtn(Icons.directions, 'Directions', () => context.push('/map')),
                          _buildActionBtn(Icons.chat_bubble_outline, 'Discreet Chat', () => context.push('/messaging')),
                          _buildActionBtn(Icons.call_outlined, 'Call Desk', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Dialing ${hub.phone}...')),
                            );
                          }),
                          _buildActionBtn(Icons.flag_outlined, 'Report', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Audit report submitted.')),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // In-Stock Today Section
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('In-Stock Today', style: AppTypography.labelLG()),
                          Text('Updated 18m ago', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildStockMeter('Regular Flow Day Pads (Wings)', hub.stockDayPads, 70, AppColors.success),
                      const SizedBox(height: 10),
                      _buildStockMeter('Heavy Flow Overnight Pads', hub.stockOvernightPads, 50, AppColors.success),
                      const SizedBox(height: 10),
                      _buildStockMeter('AFRIpads Reusable Kit', hub.stockReusableKits, 20, AppColors.coralPink),
                      const SizedBox(height: 10),
                      _buildStockMeter('Discreet Kraft Bags', hub.stockDiscreetBags, 100, AppColors.primaryContainer),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Discreet Collection Protocol
                DignityCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: AppColors.primaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text('Discreet Collection Protocol', style: AppTypography.labelLG()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildProtocolStep('1', 'Enter via Gate B / Outpatient Wing (avoid main triage queue)'),
                      _buildProtocolStep('2', 'Approach Counter 3 and state or show code: PAD-749'),
                      _buildProtocolStep('3', 'Receive opaque, unlabelled paper parcel. No ID or name asked.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Safe Amenities Badges
                DignityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safe Amenities & Dignity Access', style: AppTypography.labelLG()),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          DignityBadge(text: 'Private Cubicle', icon: Icon(Icons.meeting_room, size: 14, color: AppColors.primaryContainer)),
                          DignityBadge(text: 'Female Attendant', icon: Icon(Icons.female, size: 14, color: AppColors.primaryContainer)),
                          DignityBadge(text: 'Wheelchair Ramp', icon: Icon(Icons.accessible, size: 14, color: AppColors.primaryContainer)),
                          DignityBadge(text: 'Free Clean Water', icon: Icon(Icons.water_drop, size: 14, color: AppColors.primaryContainer)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sticky Bottom Action
                DignityButton(
                  text: 'Request Discreet Pickup Pack',
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  onPressed: () => context.push('/requests'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: AppRadius.mdBorder,
              ),
              child: Icon(icon, color: AppColors.primaryContainer, size: 20),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.labelSM(color: AppColors.neutralDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMeter(String name, int count, int max, Color fill) {
    final pct = (count / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTypography.bodySM()),
            Text('$count in stock', style: AppTypography.labelSM(color: fill)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(fill),
          ),
        ),
      ],
    );
  }

  Widget _buildProtocolStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primaryContainer,
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTypography.bodySM())),
        ],
      ),
    );
  }
}
