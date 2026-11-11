import 'package:flutter/foundation.dart';

enum LocationPermissionState {
  granted,
  denied,
  restricted,
  manualOnly,
}

class PermissionService {
  static LocationPermissionState _currentLocationState =
      LocationPermissionState.granted;

  static LocationPermissionState get locationState => _currentLocationState;

  static Future<LocationPermissionState> requestLocationPermission() async {
    // In Flutter, simulates or integrates native permission checks
    // Default to granted for seamless experience, but permits toggling
    _currentLocationState = LocationPermissionState.granted;
    return _currentLocationState;
  }

  static void setLocationPermission(LocationPermissionState state) {
    _currentLocationState = state;
    if (kDebugMode) {
      debugPrint('📍 [PermissionService] Location permission set to $state');
    }
  }

  static bool get hasLocationAccess =>
      _currentLocationState == LocationPermissionState.granted;
}
