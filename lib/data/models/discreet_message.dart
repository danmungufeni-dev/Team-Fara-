class DiscreetMessage {
  final String id;
  final String voucherCode;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSeeker;
  final bool isDelivered;
  final bool isRead;

  const DiscreetMessage({
    required this.id,
    required this.voucherCode,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isSeeker,
    this.isDelivered = true,
    this.isRead = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'voucher_code': voucherCode,
        'sender_id': senderId,
        'sender_name': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'is_seeker': isSeeker,
        'is_delivered': isDelivered,
        'is_read': isRead,
      };

  factory DiscreetMessage.fromJson(Map<String, dynamic> json) =>
      DiscreetMessage(
        id: json['id'] as String,
        voucherCode: (json['voucher_code'] ?? json['voucherCode']) as String,
        senderId: (json['sender_id'] ?? json['senderId']) as String,
        senderName: (json['sender_name'] ?? json['senderName']) as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isSeeker: (json['is_seeker'] ?? json['isSeeker']) as bool? ?? true,
        isDelivered: (json['is_delivered'] ?? json['isDelivered']) as bool? ?? false,
        isRead: (json['is_read'] ?? json['isRead']) as bool? ?? false,
      );
}
