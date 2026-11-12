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
        'voucher_code': voucherCode,
        'hub_id': hubId,
        'hub_name': hubName,
        'allocation_summary': allocationSummary,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'pickup_window': pickupWindow,
        'pin': pin,
      };

  factory RequestVoucher.fromJson(Map<String, dynamic> json) => RequestVoucher(
        id: json['id'] as String,
        voucherCode: (json['voucher_code'] ?? json['voucherCode']) as String,
        hubId: (json['hub_id'] ?? json['hubId']) as String,
        hubName: (json['hub_name'] ?? json['hubName']) as String,
        allocationSummary: (json['allocation_summary'] ?? json['allocationSummary']) as String,
        status: VoucherStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => VoucherStatus.readyForPickup,
        ),
        createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
        expiresAt: DateTime.parse((json['expires_at'] ?? json['expiresAt']) as String),
        pickupWindow: (json['pickup_window'] ?? json['pickupWindow']) as String? ?? 'Within the next 2 hours',
        pin: json['pin'] as String? ?? '749',
      );
}
