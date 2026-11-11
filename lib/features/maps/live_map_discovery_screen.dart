import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/models/distribution_point.dart';
import '../../data/services/mock_backend_store.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/dignity_badge.dart';
import '../../shared/widgets/dignity_button.dart';
import '../../shared/widgets/dignity_card.dart';
import '../../shared/widgets/dignity_chip.dart';

class LiveMapDiscoveryScreen extends StatefulWidget {
  final String? initialQuery;

  const LiveMapDiscoveryScreen({super.key, this.initialQuery});

  @override
  State<LiveMapDiscoveryScreen> createState() => _LiveMapDiscoveryScreenState();
}

class _LiveMapDiscoveryScreenState extends State<LiveMapDiscoveryScreen> {
  final MockBackendStore _store = MockBackendStore();
  bool _isMapView = true;
  String _selectedCity = 'Kampala';
  String _activeFilter = 'Available Now';
  DistributionPoint? _selectedHub;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _eacCities = const [
    {'flag': '🇺🇬', 'city': 'Kampala'},
    {'flag': '🇰🇪', 'city': 'Nairobi'},
    {'flag': '🇹🇿', 'city': 'Dar es Salaam'},
    {'flag': '🇷🇼', 'city': 'Kigali'},
    {'flag': '🇧🇮', 'city': 'Bujumbura'},
    {'flag': '🇸🇸', 'city': 'Juba'},
    {'flag': '🇨🇩', 'city': 'Goma'},
  ];

  final List<String> _filters = const [
    'Available Now',
    '100% Free',
    'Gov & NGO Verified',
    'EAC Cross-Border',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    if (_store.hubs.isNotEmpty) {
      _selectedHub = _store.hubs.first;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hubs = _store.hubs;

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
            Text('Live Map Discovery', style: AppTypography.headlineSM()),
            Text('Kampala • EAC Corridor', style: AppTypography.labelSM(color: AppColors.neutralMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Add Hub',
            onPressed: () => context.push('/add-distribution-point'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Stack(
            children: [
              Column(
                children: [
                  // Search & View Toggle Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: AppRadius.mdBorder,
                              border: Border.all(color: AppColors.borderSubtle),
                              boxShadow: AppElevation.level1,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: AppColors.neutralMuted, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search hubs or areas...',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Map / List Toggle
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: AppRadius.mdBorder,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.map,
                                  color: _isMapView ? AppColors.primaryContainer : AppColors.neutralMuted,
                                ),
                                onPressed: () => setState(() => _isMapView = true),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.format_list_bulleted,
                                  color: !_isMapView ? AppColors.primaryContainer : AppColors.neutralMuted,
                                ),
                                onPressed: () => setState(() => _isMapView = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // EAC Multi-City Horizontal Carousel
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _eacCities.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = _eacCities[index];
                        final isSelected = item['city'] == _selectedCity;
                        return DignityChip(
                          label: '${item['flag']} ${item['city']}',
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedCity = item['city']!),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filter Chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = filter == _activeFilter;
                        return InkWell(
                          onTap: () => setState(() => _activeFilter = filter),
                          borderRadius: AppRadius.fullBorder,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                              borderRadius: AppRadius.fullBorder,
                            ),
                            child: Text(
                              filter,
                              style: AppTypography.labelSM(
                                color: isSelected ? Colors.white : AppColors.neutralDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Main View: Map or List
                  Expanded(
                    child: _isMapView
                        ? _buildInteractiveMap(hubs)
                        : _buildListView(hubs),
                  ),
                ],
              ),

              // Floating Selected Hub Preview Card (on Map View)
              if (_isMapView && _selectedHub != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: DignityCard(
                    boxShadow: AppElevation.level3,
                    onTap: () => context.push('/hub-details/${_selectedHub!.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const DignityBadge(
                              text: 'Verified MOH Hub',
                              variant: DignityBadgeVariant.verified,
                            ),
                            const Spacer(),
                            Text(
                              '${_selectedHub!.walkingTimeMinutes} mins walk',
                              style: AppTypography.labelSM(color: AppColors.neutralMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedHub!.name,
                          style: AppTypography.labelLG(color: AppColors.neutralDark),
                        ),
                        Text(
                          _selectedHub!.address,
                          style: AppTypography.bodySM(color: AppColors.neutralMuted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${_selectedHub!.stockDayPads} Day Pads in stock',
                              style: AppTypography.labelSM(color: AppColors.success),
                            ),
                            const Spacer(),
                            DignityButton(
                              text: 'Reserve Pack',
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              onPressed: () => context.push('/requests'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (idx) {
          switch (idx) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              break;
            case 2:
              context.push('/requests');
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

  Widget _buildInteractiveMap(List<DistributionPoint> hubs) {
    return Container(
      color: const Color(0xFFE5E3DF),
      child: Stack(
        children: [
          // Simulated Map Grid with subtle roads and terrain
          CustomPaint(
            size: Size.infinite,
            painter: _MapCanvasPainter(),
          ),

          // User Current Location Marker
          Positioned(
            left: 120,
            top: 220,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.fullBorder,
                    boxShadow: AppElevation.level1,
                  ),
                  child: Text('You are here (Wandegeya)', style: AppTypography.labelSM()),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: AppElevation.level2,
                  ),
                ),
              ],
            ),
          ),

          // Distribution Point Markers
          for (int i = 0; i < hubs.length; i++)
            Positioned(
              left: 60.0 + (i * 90.0) % 240,
              top: 100.0 + (i * 110.0) % 280,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedHub = hubs[i]);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedHub?.id == hubs[i].id
                            ? AppColors.primaryContainer
                            : Colors.white,
                        borderRadius: AppRadius.fullBorder,
                        boxShadow: AppElevation.level1,
                      ),
                      child: Text(
                        hubs[i].name.split(' ').first,
                        style: AppTypography.labelSM(
                          color: _selectedHub?.id == hubs[i].id
                              ? Colors.white
                              : AppColors.neutralDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.location_on,
                      size: 38,
                      color: _selectedHub?.id == hubs[i].id
                          ? AppColors.coralPink
                          : AppColors.primaryContainer,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(List<DistributionPoint> hubs) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: hubs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final hub = hubs[index];
        return DignityCard(
          onTap: () => context.push('/hub-details/${hub.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(hub.name, style: AppTypography.labelLG()),
                  Text('${hub.distanceMeters.toInt()}m', style: AppTypography.labelSM()),
                ],
              ),
              const SizedBox(height: 4),
              Text(hub.address, style: AppTypography.bodySM(color: AppColors.neutralMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFF4B400)),
                  const SizedBox(width: 4),
                  Text('${hub.rating}', style: AppTypography.labelSM()),
                  const SizedBox(width: 12),
                  Text('${hub.stockDayPads} packs', style: AppTypography.labelSM(color: AppColors.success)),
                  const Spacer(),
                  Text(hub.openHours, style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFD6D2CA)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadMinorPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw main arterial road
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.45, size.width, size.height * 0.2);
    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, roadMinorPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.6, size.width * 0.7, size.height);
    canvas.drawPath(path2, roadPaint);
    canvas.drawPath(path2, roadMinorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
