import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:padcare/core/services/location_service.dart';

void main() {
  late LocationService locationService;

  setUp(() {
    locationService = LocationService.instance;
  });

  group('LocationService Realtime Maps & Distance Tests', () {
    test('Calculates distance in meters accurately between Kampala coordinates', () {
      const from = LatLng(0.3136, 32.5811); // Wandegeya
      const to = LatLng(0.3136, 32.5711); // Kisenyi Health Center IV

      final meters = locationService.calculateDistanceMeters(from, to);
      expect(meters, greaterThan(500));
      expect(meters, lessThan(2000));
    });

    test('Formats distance correctly for meters and kilometers', () {
      expect(locationService.formatDistance(450), '450 m');
      expect(locationService.formatDistance(850), '850 m');
      expect(locationService.formatDistance(1400), '1.4 km');
      expect(locationService.formatDistance(2300), '2.3 km');
    });

    test('Estimates walking time in minutes based on 1.3m/s speed', () {
      final walk850m = locationService.estimateWalkingMinutes(850);
      expect(walk850m, inInclusiveRange(10, 12));

      final walk1400m = locationService.estimateWalkingMinutes(1400);
      expect(walk1400m, inInclusiveRange(17, 20));
    });

    test('Toggles movement simulation mode on and off', () {
      expect(locationService.isSimulating, isFalse);
      locationService.toggleSimulation(enable: true);
      expect(locationService.isSimulating, isTrue);

      locationService.toggleSimulation(enable: false);
      expect(locationService.isSimulating, isFalse);
    });

    test('EAC city coordinates include Kampala, Nairobi, Kigali and Dar es Salaam', () {
      expect(LocationService.eacCityCoordinates.containsKey('Kampala'), isTrue);
      expect(LocationService.eacCityCoordinates.containsKey('Nairobi'), isTrue);
      expect(LocationService.eacCityCoordinates.containsKey('Kigali'), isTrue);
      expect(LocationService.eacCityCoordinates.containsKey('Dar es Salaam'), isTrue);
    });
  });
}
