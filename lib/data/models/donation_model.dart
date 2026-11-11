enum PaymentProvider {
  mtnMomo,
  airtelMoney,
  mPesa,
  rwandaPay,
  card,
}

enum DonationFrequency {
  oneTime,
  monthly,
}

class DonationModel {
  final String id;
  final String reference;
  final num amountUgx;
  final int kitPercent;
  final int devPercent;
  final PaymentProvider provider;
  final String phoneNumber;
  final DonationFrequency frequency;
  final DateTime timestamp;
  final bool isCompleted;

  const DonationModel({
    required this.id,
    required this.reference,
    required this.amountUgx,
    this.kitPercent = 80,
    this.devPercent = 20,
    required this.provider,
    required this.phoneNumber,
    this.frequency = DonationFrequency.oneTime,
    required this.timestamp,
    this.isCompleted = true,
  });

  num get kitAmountUgx => (amountUgx * kitPercent) / 100;
  num get devAmountUgx => (amountUgx * devPercent) / 100;

  num get kesEquivalent => (amountUgx * 0.0347).round();
  num get tzsEquivalent => (amountUgx * 0.70).round();
  num get rwfEquivalent => (amountUgx * 0.36).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'amountUgx': amountUgx,
        'kitPercent': kitPercent,
        'devPercent': devPercent,
        'provider': provider.name,
        'phoneNumber': phoneNumber,
        'frequency': frequency.name,
        'timestamp': timestamp.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory DonationModel.fromJson(Map<String, dynamic> json) => DonationModel(
        id: json['id'] as String,
        reference: json['reference'] as String,
        amountUgx: json['amountUgx'] as num,
        kitPercent: json['kitPercent'] as int? ?? 80,
        devPercent: json['devPercent'] as int? ?? 20,
        provider: PaymentProvider.values.firstWhere(
          (e) => e.name == json['provider'],
          orElse: () => PaymentProvider.mtnMomo,
        ),
        phoneNumber: json['phoneNumber'] as String,
        frequency: DonationFrequency.values.firstWhere(
          (e) => e.name == json['frequency'],
          orElse: () => DonationFrequency.oneTime,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isCompleted: json['isCompleted'] as bool? ?? true,
      );
}
