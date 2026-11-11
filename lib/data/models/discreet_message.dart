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
        'voucherCode': voucherCode,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isSeeker': isSeeker,
        'isDelivered': isDelivered,
        'isRead': isRead,
      };

  factory DiscreetMessage.fromJson(Map<String, dynamic> json) =>
      DiscreetMessage(
        id: json['id'] as String,
        voucherCode: json['voucherCode'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isSeeker: json['isSeeker'] as bool? ?? true,
        isDelivered: json['isDelivered'] as bool? ?? true,
        isRead: json['isRead'] as bool? ?? true,
      );
}
