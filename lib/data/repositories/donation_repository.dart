import 'dart:math';
import '../models/donation_model.dart';

abstract class IDonationRepository {
  Future<DonationModel> processDonation({
    required num amountUgx,
    required int kitPercent,
    required int devPercent,
    required PaymentProvider provider,
    required String phoneNumber,
    required DonationFrequency frequency,
  });
}

class DonationRepository implements IDonationRepository {
  DonationModel? lastCompletedDonation;

  @override
  Future<DonationModel> processDonation({
    required num amountUgx,
    required int kitPercent,
    required int devPercent,
    required PaymentProvider provider,
    required String phoneNumber,
    required DonationFrequency frequency,
  }) async {
    final rand = Random();
    final refSuffix = 1000 + rand.nextInt(9000);
    final reference = 'TXN-EAC-202505-$refSuffix';

    final donation = DonationModel(
      id: 'don_${DateTime.now().millisecondsSinceEpoch}',
      reference: reference,
      amountUgx: amountUgx,
      kitPercent: kitPercent,
      devPercent: devPercent,
      provider: provider,
      phoneNumber: phoneNumber,
      frequency: frequency,
      timestamp: DateTime.now(),
      isCompleted: true,
    );

    lastCompletedDonation = donation;
    return donation;
  }
}
