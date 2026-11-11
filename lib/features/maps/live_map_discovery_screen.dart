import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_elevation.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/services/location_service.dart';
import '../../core/services/supabase_service.dart';
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

class _LiveMapDiscoveryScreenState extends State<LiveMapDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final MockBackendStore _store = MockBackendStore();
  final LocationService _locationService = LocationService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<LatLng>? _locationSubscription;
  StreamSubscription<List<DistributionPoint>>? _hubsSubscription;

  LatLng _userLocation = LocationService.defaultKampala;
  List<DistributionPoint> _liveHubs = [];
  DistributionPoint? _selectedHub;

  bool _isMapView = true;
  bool _followUser = true;
  String _selectedCity = 'Kampala';
  String _activeFilter = 'Available Now';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _liveHubs = List.from(_store.hubs);
    if (_liveHubs.isNotEmpty) {
      _selectedHub = _liveHubs.first;
    }

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }

    // Pulse animation for user's realtime location radar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 8.0, end: 28.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _initRealtimeTracking();
  }

  void _initRealtimeTracking() {
    // 1. Realtime Hubs stream from Supabase/Backend
    _hubsSubscription = _supabaseService.streamDistributionPoints().listen((hubs) {
      if (mounted) {
        setState(() {
          _liveHubs = hubs;
          if (_selectedHub != null) {
            _selectedHub = hubs.firstWhere(
              (h) => h.id == _selectedHub!.id,
              orElse: () => hubs.first,
            );
          }
        });
      }
    });

    // 2. Realtime user location tracking
    _locationSubscription = _locationService.getRealtimeLocationStream().listen((coords) {
      if (mounted) {
        setState(() {
          _userLocation = coords;
        });

        if (_followUser) {
          _mapController.move(coords, _mapController.camera.zoom);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationSubscription?.cancel();
    _hubsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _moveToCity(String city) {
    setState(() => _selectedCity = city);
    final coords = LocationService.eacCityCoordinates[city];
    if (coords != null) {
      _mapController.move(coords, 13.5);
    }
  }

  void _recenterOnUser() {
    setState(() => _followUser = true);
    _mapController.move(_userLocation, 15.0);
  }

  List<DistributionPoint> _getFilteredHubs() {
    List<DistributionPoint> list = _liveHubs.isNotEmpty ? _liveHubs : _store.hubs;

    // Filter by city if not EAC Cross-Border
    if (_activeFilter != 'EAC Cross-Border') {
      list = list.where((h) => h.city.toLowerCase() == _selectedCity.toLowerCase()).toList();
      if (list.isEmpty) {
        // Fallback to all if selected city has no hubs registered yet
        list = _liveHubs.isNotEmpty ? _liveHubs : _store.hubs;
      }
    }

    // Filter by active pill
    if (_activeFilter == 'Available Now') {
      list = list.where((h) => h.isAvailable).toList();
    } else if (_activeFilter == 'Gov & NGO Verified') {
      list = list.where((h) => h.isVerified).toList();
    }

    // Search query filter
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.category.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredHubs = _getFilteredHubs();

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
            Row(
              children: [
                Text(context.tr('liveMapTitle'), style: AppTypography.headlineSM()),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _supabaseService.isLiveSupabase
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.secondaryContainer,
                    borderRadius: AppRadius.fullBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 11,
                        color: _supabaseService.isLiveSupabase
                            ? AppColors.success
                            : AppColors.primaryContainer,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _supabaseService.isLiveSupabase ? 'Supabase Realtime' : 'Realtime GPS',
                        style: AppTypography.labelSM(
                          color: _supabaseService.isLiveSupabase
                              ? AppColors.success
                              : AppColors.primaryContainer,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              '$_selectedCity • Live GPS & Hub Coordinates',
              style: AppTypography.labelSM(color: AppColors.neutralMuted),
            ),
          ],
        ),
        actions: [
          // Simulated movement toggle for testing
          IconButton(
            icon: Icon(
              _locationService.isSimulating ? Icons.directions_walk : Icons.gps_fixed,
              color: _locationService.isSimulating ? AppColors.coralPink : AppColors.neutralDark,
            ),
            tooltip: _locationService.isSimulating
                ? 'Stop Movement Simulation'
                : 'Simulate Walking Movement',
            onPressed: () {
              setState(() {
                _locationService.toggleSimulation();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _locationService.isSimulating
                        ? 'Realtime walking simulation started along Kampala route!'
                        : 'Switched back to device hardware GPS.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
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
                                    decoration: InputDecoration(
                                      hintText: context.tr('searchPlaceholder'),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      fillColor: Colors.transparent,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
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
                                  color: _isMapView
                                      ? AppColors.primaryContainer
                                      : AppColors.neutralMuted,
                                ),
                                onPressed: () => setState(() => _isMapView = true),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.format_list_bulleted,
                                  color: !_isMapView
                                      ? AppColors.primaryContainer
                                      : AppColors.neutralMuted,
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
                          onTap: () => _moveToCity(item['city']!),
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
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh,
                              borderRadius: AppRadius.fullBorder,
                            ),
                            child: Text(
                              context.tr(filter),
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

                  // Main View: Realtime OpenStreetMap or List View
                  Expanded(
                    child: _isMapView
                        ? _buildInteractiveOsmMap(filteredHubs)
                        : _buildListView(filteredHubs),
                  ),
                ],
              ),

              // Floating Selected Hub Preview Card (on Map View)
              if (_isMapView && _selectedHub != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildSelectedHubCard(_selectedHub!),
                ),

              // Map Floating Action Controls (Recenter, Zoom, Simulation indicator)
              if (_isMapView)
                Positioned(
                  right: 16,
                  top: 150,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'recenter_gps',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryContainer,
                        tooltip: 'Recenter on My Location',
                        onPressed: _recenterOnUser,
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.neutralDark,
                        tooltip: 'Zoom In',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.neutralDark,
                        tooltip: 'Zoom Out',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ],
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

  Widget _buildInteractiveOsmMap(List<DistributionPoint> hubs) {
    // Generate route polyline between user and selected hub
    final List<LatLng> routePoints = [];
    if (_selectedHub != null) {
      routePoints.add(_userLocation);
      // Realistic intermediate waypoint for demonstration
      final midLat = (_userLocation.latitude + _selectedHub!.latitude) / 2;
      final midLng = (_userLocation.longitude + _selectedHub!.longitude) / 2;
      routePoints.add(LatLng(midLat, midLng));
      routePoints.add(LatLng(_selectedHub!.latitude, _selectedHub!.longitude));
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation,
        initialZoom: 14.5,
        onPositionChanged: (pos, hasGesture) {
          if (hasGesture && _followUser) {
            setState(() => _followUser = false);
          }
        },
      ),
      children: [
        // Free, Worldwide OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'org.padcare.app',
          maxZoom: 19,
        ),

        // Walking route polyline to selected hub
        if (routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.5,
                color: AppColors.primaryContainer,
                borderColor: Colors.white,
                borderStrokeWidth: 2.0,
              ),
            ],
          ),

        // Hub Markers and Realtime User Location Marker
        MarkerLayer(
          markers: [
            // User Realtime GPS Marker with Animated Radar Pulse
            Marker(
              point: _userLocation,
              width: 70,
              height: 70,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing radar wave
                      Container(
                        width: _pulseAnimation.value * 2,
                        height: _pulseAnimation.value * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withValues(
                            alpha: (1.0 - (_pulseController.value)).clamp(0.0, 0.5),
                          ),
                        ),
                      ),
                      // Core location dot
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: AppElevation.level2,
                        ),
                      ),
                      // Heading arrow indicator
                      const Positioned(
                        top: 14,
                        child: Icon(
                          Icons.navigation,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Distribution Points Markers
            for (final hub in hubs)
              Marker(
                point: LatLng(hub.latitude, hub.longitude),
                width: 110,
                height: 65,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedHub = hub);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _selectedHub?.id == hub.id
                              ? AppColors.primaryContainer
                              : Colors.white,
                          borderRadius: AppRadius.fullBorder,
                          border: Border.all(
                            color: _selectedHub?.id == hub.id
                                ? Colors.white
                                : AppColors.primaryContainer,
                            width: 1.5,
                          ),
                          boxShadow: AppElevation.level2,
                        ),
                        child: Text(
                          hub.name.split(' ').first,
                          style: AppTypography.labelSM(
                            color: _selectedHub?.id == hub.id
                                ? Colors.white
                                : AppColors.neutralDark,
                          ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 36,
                        color: _selectedHub?.id == hub.id
                            ? AppColors.coralPink
                            : AppColors.primaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedHubCard(DistributionPoint hub) {
    // Calculate live distance & walking time from current user GPS coordinates
    final hubLatLng = LatLng(hub.latitude, hub.longitude);
    final distanceMeters = _locationService.calculateDistanceMeters(_userLocation, hubLatLng);
    final distanceText = _locationService.formatDistance(distanceMeters);
    final walkingMinutes = _locationService.estimateWalkingMinutes(distanceMeters);

    return DignityCard(
      boxShadow: AppElevation.level3,
      onTap: () => context.push('/hub-details/${hub.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const DignityBadge(
                text: 'Verified Safe Hub',
                variant: DignityBadgeVariant.verified,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: AppRadius.fullBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_walk, size: 14, color: AppColors.primaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '$distanceText • $walkingMinutes mins walk',
                      style: AppTypography.labelSM(color: AppColors.primaryContainer)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hub.name,
            style: AppTypography.labelLG(color: AppColors.neutralDark),
          ),
          Text(
            hub.address,
            style: AppTypography.bodySM(color: AppColors.neutralMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${hub.stockDayPads} Day Pads in stock',
                style: AppTypography.labelSM(color: AppColors.success),
              ),
              const Spacer(),
              DignityButton(
                text: context.tr('reservePack'),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                onPressed: () => context.push('/requests'),
              ),
            ],
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
        final hubLatLng = LatLng(hub.latitude, hub.longitude);
        final distanceMeters =
            _locationService.calculateDistanceMeters(_userLocation, hubLatLng);
        final distanceText = _locationService.formatDistance(distanceMeters);

        return DignityCard(
          onTap: () => context.push('/hub-details/${hub.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hub.name,
                      style: AppTypography.labelLG(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    distanceText,
                    style: AppTypography.labelSM(color: AppColors.primaryContainer)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
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
                  Text('${hub.stockDayPads} packs',
                      style: AppTypography.labelSM(color: AppColors.success)),
                  const Spacer(),
                  Text(hub.openHours,
                      style: AppTypography.labelSM(color: AppColors.neutralMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
