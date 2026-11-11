import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/data/models/donation_model.dart';
import 'package:padcare/data/repositories/donation_repository.dart';

void main() {
  group('Donation Repository & Model Tests', () {
    test('Calculates 80/20 split correctly for 15,000 UGX', () {
      final donation = DonationModel(
        id: 'don_1',
        reference: 'TXN-EAC-202505-8842',
        amountUgx: 15000,
        kitPercent: 80,
        devPercent: 20,
        provider: PaymentProvider.mtnMomo,
        phoneNumber: '+256772449881',
        timestamp: DateTime.now(),
      );

      expect(donation.kitAmountUgx, 12000);
      expect(donation.devAmountUgx, 3000);
    });

    test('Computes live EAC regional currency equivalents', () {
      final donation = DonationModel(
        id: 'don_2',
        reference: 'TXN-EAC-202505-8843',
        amountUgx: 15000,
        provider: PaymentProvider.mPesa,
        phoneNumber: '+254712890123',
        timestamp: DateTime.now(),
      );

      expect(donation.kesEquivalent, 521); // ~520 KES
      expect(donation.tzsEquivalent, 10500); // 10,500 TZS
      expect(donation.rwfEquivalent, 5400); // 5,400 RWF
    });

    test('Processing donation returns valid completed model', () async {
      final repo = DonationRepository();
      final result = await repo.processDonation(
        amountUgx: 35000,
        kitPercent: 75,
        devPercent: 25,
        provider: PaymentProvider.airtelMoney,
        phoneNumber: '+256701334112',
        frequency: DonationFrequency.oneTime,
      );

      expect(result.amountUgx, 35000);
      expect(result.isCompleted, true);
      expect(result.reference, startsWith('TXN-EAC-'));
    });
  });
}
