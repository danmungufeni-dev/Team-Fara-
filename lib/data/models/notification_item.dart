enum NotificationCategory {
  all,
  reservations,
  stock,
  community,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime timestamp;
  final String? timeLeft;
  final String? hubName;
  final String? distance;
  final String? voucherCode;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.timeLeft,
    this.hubName,
    this.distance,
    this.voucherCode,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      category: category,
      timestamp: timestamp,
      timeLeft: timeLeft,
      hubName: hubName,
      distance: distance,
      voucherCode: voucherCode,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category.name,
        'timestamp': timestamp.toIso8601String(),
        'timeLeft': timeLeft,
        'hubName': hubName,
        'distance': distance,
        'voucherCode': voucherCode,
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        category: NotificationCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => NotificationCategory.all,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        timeLeft: json['timeLeft'] as String?,
        hubName: json['hubName'] as String?,
        distance: json['distance'] as String?,
        voucherCode: json['voucherCode'] as String?,
        isRead: json['isRead'] as bool? ?? false,
      );
}
