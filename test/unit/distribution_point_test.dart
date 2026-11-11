import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/data/models/distribution_point.dart';
import 'package:padcare/data/repositories/distribution_point_repository.dart';

void main() {
  group('DistributionPointRepository Tests', () {
    test('Fetches default hubs in Kampala', () async {
      final repo = DistributionPointRepository();
      final hubs = await repo.getHubs();
      expect(hubs.isNotEmpty, true);
      expect(hubs.any((h) => h.name.contains('Kisenyi')), true);
    });

    test('Filters hubs by query', () async {
      final repo = DistributionPointRepository();
      final results = await repo.getHubs(query: 'WoMena');
      expect(results.length, 1);
      expect(results.first.name, contains('WoMena'));
    });

    test('Calculates total stock available in distribution point', () {
      const hub = DistributionPoint(
        id: 'test_hub',
        name: 'Test Safe Hub',
        category: 'Clinic',
        distanceMeters: 500,
        walkingTimeMinutes: 6,
        address: 'Kampala',
        latitude: 0.31,
        longitude: 32.58,
        stockDayPads: 40,
        stockOvernightPads: 20,
        stockReusableKits: 10,
      );

      expect(hub.totalStock, 70);
      expect(hub.isAvailable, true);
    });
  });
}
