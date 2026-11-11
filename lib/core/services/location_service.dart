import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService.instance;
});

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // Default coordinate: Kampala Central / Wandegeya
  static const LatLng defaultKampala = LatLng(0.3136, 32.5811);

  // Regional EAC City coordinates
  static const Map<String, LatLng> eacCityCoordinates = {
    'Kampala': LatLng(0.3476, 32.5825),
    'Nairobi': LatLng(-1.2921, 36.8219),
    'Dar es Salaam': LatLng(-6.7924, 39.2083),
    'Kigali': LatLng(-1.9441, 30.0619),
    'Bujumbura': LatLng(-3.3822, 29.3644),
    'Juba': LatLng(4.8594, 31.5713),
    'Goma': LatLng(-1.6741, 29.2285),
  };

  Timer? _simulationTimer;
  final StreamController<LatLng> _simulatedLocationController =
      StreamController<LatLng>.broadcast();
  bool _isSimulating = false;
  int _simStep = 0;

  bool get isSimulating => _isSimulating;

  /// Check whether GPS location service is enabled and permission is granted.
  Future<bool> hasPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Request runtime location permission.
  Future<bool> requestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('⚠️ [LocationService] Permission request failed: $e');
      return false;
    }
  }

  /// Get current GPS location. If permission is denied or fails,
  /// returns [defaultKampala].
  Future<LatLng> getCurrentLocation() async {
    try {
      final permitted = await requestPermission();
      if (permitted) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        return LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      debugPrint('ℹ️ [LocationService] GPS fetch fallback to default: $e');
    }
    return defaultKampala;
  }

  /// Realtime stream of user position changes.
  /// Combines hardware GPS stream with simulation stream if active.
  Stream<LatLng> getRealtimeLocationStream() {
    late StreamController<LatLng> controller;
    StreamSubscription? gpsSub;
    StreamSubscription? simSub;

    controller = StreamController<LatLng>.broadcast(
      onListen: () async {
        // First emit current or default position
        final initial = await getCurrentLocation();
        if (!controller.isClosed) controller.add(initial);

        // Listen to simulation stream
        simSub = _simulatedLocationController.stream.listen((latLng) {
          if (!controller.isClosed) controller.add(latLng);
        });

        // Try listening to real device GPS stream
        try {
          final permitted = await hasPermission();
          if (permitted) {
            const locationSettings = LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3, // meters
            );
            gpsSub = Geolocator.getPositionStream(
              locationSettings: locationSettings,
            ).listen((pos) {
              if (!_isSimulating && !controller.isClosed) {
                controller.add(LatLng(pos.latitude, pos.longitude));
              }
            }, onError: (err) {
              debugPrint('ℹ️ [LocationService] GPS stream error: $err');
            });
          }
        } catch (_) {}
      },
      onCancel: () {
        gpsSub?.cancel();
        simSub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Start or stop simulated walking movement around Kampala
  /// for live demo/testing without requiring real movement.
  void toggleSimulation({bool? enable}) {
    final target = enable ?? !_isSimulating;
    _isSimulating = target;

    if (_isSimulating) {
      debugPrint('🏃 [LocationService] Live movement simulation started');
      _simulationTimer?.cancel();

      // Walking path coordinates around Kampala Central / Kisenyi
      final path = [
        const LatLng(0.3136, 32.5811), // Wandegeya
        const LatLng(0.3145, 32.5795),
        const LatLng(0.3160, 32.5780),
        const LatLng(0.3175, 32.5765),
        const LatLng(0.3190, 32.5745),
        const LatLng(0.3170, 32.5730),
        const LatLng(0.3150, 32.5715),
        const LatLng(0.3136, 32.5711), // Kisenyi Health Center IV
        const LatLng(0.3120, 32.5725),
        const LatLng(0.3105, 32.5740),
        const LatLng(0.3090, 32.5760),
      ];

      _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _simStep = (_simStep + 1) % path.length;
        final nextCoord = path[_simStep];
        _simulatedLocationController.add(nextCoord);
      });
    } else {
      debugPrint('🛑 [LocationService] Live movement simulation stopped');
      _simulationTimer?.cancel();
      _simulationTimer = null;
    }
  }

  /// Calculate distance in meters between two coordinates
  double calculateDistanceMeters(LatLng from, LatLng to) {
    try {
      return Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
    } catch (_) {
      // Fallback Euclidean approximate in meters
      final latDiff = (from.latitude - to.latitude) * 111000;
      final lngDiff = (from.longitude - to.longitude) * 111000;
      return (latDiff * latDiff + lngDiff * lngDiff);
    }
  }

  /// Formats meters into human-readable distance (e.g. "450 m" or "1.8 km")
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Estimate walking time in minutes based on average 1.3 m/s walking speed
  int estimateWalkingMinutes(double meters) {
    final seconds = meters / 1.3;
    final minutes = (seconds / 60).ceil();
    return minutes > 0 ? minutes : 1;
  }
}
