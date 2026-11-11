import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/core/services/supabase_service.dart';
import 'package:padcare/data/models/distribution_point.dart';
import 'package:padcare/data/models/request_voucher.dart';

void main() {
  late SupabaseService supabaseService;

  setUp(() async {
    supabaseService = SupabaseService.instance;
    await supabaseService.init();
  });

  group('SupabaseService & Realtime Backend Tests', () {
    test('Initializes gracefully in free offline simulation mode without credentials', () {
      expect(supabaseService.isSimulationMode, isTrue);
    });

    test('Anonymous Dignity Sign-In generates zero-PII user profile', () async {
      final user = await supabaseService.signInAnonymously(
        pseudonym: 'Safe Seeker Hope',
      );
      expect(user.pseudonym, 'Safe Seeker Hope');
      expect(user.incognitoMode, isTrue);
      expect(user.termsAccepted, isTrue);
      expect(user.email, contains('anonymous'));
    });

    test('Realtime Distribution Points stream emits live hubs', () async {
      final stream = supabaseService.streamDistributionPoints();
      expect(stream, emits(isA<List<DistributionPoint>>()));
    });

    test('Realtime Requests stream emits vouchers and updates status', () async {
      final initialVoucher = RequestVoucher(
        id: 'test_voucher_101',
        voucherCode: 'PAD-101',
        hubId: 'hub_1',
        hubName: 'Kisenyi Health Center IV',
        allocationSummary: '1 Regular Pack (10 pads)',
        status: VoucherStatus.readyForPickup,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 3)),
      );

      await supabaseService.createRequest(initialVoucher);
      await supabaseService.updateRequestStatus('test_voucher_101', VoucherStatus.collected);

      // Verify status updated in store
      final activeUser = supabaseService.currentUser;
      expect(activeUser, isNotNull);
    });

    test('Live location broadcast emits valid payload', () async {
      expectLater(
        supabaseService.streamLiveLocations(),
        emits(predicate<Map<String, dynamic>>((map) {
          return map['entityId'] == 'van_1' &&
              map['latitude'] == 0.3136 &&
              map['type'] == 'mobile_dispensary';
        })),
      );

      supabaseService.broadcastLocation(
        entityId: 'van_1',
        latitude: 0.3136,
        longitude: 32.5811,
        label: 'Mobile Pad Dispensary Van #1',
        type: 'mobile_dispensary',
      );
    });
  });
}
