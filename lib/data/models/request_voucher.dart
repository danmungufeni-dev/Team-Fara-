enum VoucherStatus {
  reserved,
  readyForPickup,
  collected,
  expired,
}

class RequestVoucher {
  final String id;
  final String voucherCode;
  final String hubId;
  final String hubName;
  final String allocationSummary;
  final VoucherStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String pickupWindow;
  final String pin;

  const RequestVoucher({
    required this.id,
    required this.voucherCode,
    required this.hubId,
    required this.hubName,
    required this.allocationSummary,
    this.status = VoucherStatus.readyForPickup,
    required this.createdAt,
    required this.expiresAt,
    this.pickupWindow = 'Within the next 2 hours',
    this.pin = '749',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  String get remainingFormatted {
    final diff = remainingTime;
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }
    return '${diff.inMinutes}m left';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'voucherCode': voucherCode,
        'hubId': hubId,
        'hubName': hubName,
        'allocationSummary': allocationSummary,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'pickupWindow': pickupWindow,
        'pin': pin,
      };

  factory RequestVoucher.fromJson(Map<String, dynamic> json) => RequestVoucher(
        id: json['id'] as String,
        voucherCode: json['voucherCode'] as String,
        hubId: json['hubId'] as String,
        hubName: json['hubName'] as String,
        allocationSummary: json['allocationSummary'] as String,
        status: VoucherStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => VoucherStatus.readyForPickup,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        pickupWindow: json['pickupWindow'] as String? ?? 'Within the next 2 hours',
        pin: json['pin'] as String? ?? '749',
      );
}
