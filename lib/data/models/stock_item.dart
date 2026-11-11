enum StockStatus {
  available,
  limited,
  outOfStock,
}

class StockItem {
  final String id;
  final String name;
  final String description;
  final int count;
  final int capacity;
  final StockStatus status;
  final int targetMinPercent;
  final String lastVerifiedBy;
  final DateTime lastVerifiedAt;

  const StockItem({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
    required this.capacity,
    required this.status,
    this.targetMinPercent = 30,
    required this.lastVerifiedBy,
    required this.lastVerifiedAt,
  });

  StockItem copyWith({int? count, StockStatus? status}) {
    final newCount = count ?? this.count;
    StockStatus newStatus = status ?? this.status;
    if (status == null) {
      if (newCount == 0) {
        newStatus = StockStatus.outOfStock;
      } else if (newCount < (capacity * targetMinPercent / 100)) {
        newStatus = StockStatus.limited;
      } else {
        newStatus = StockStatus.available;
      }
    }
    return StockItem(
      id: id,
      name: name,
      description: description,
      count: newCount,
      capacity: capacity,
      status: newStatus,
      targetMinPercent: targetMinPercent,
      lastVerifiedBy: lastVerifiedBy,
      lastVerifiedAt: DateTime.now(),
    );
  }

  int get percentage => capacity > 0 ? ((count / capacity) * 100).round() : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'count': count,
        'capacity': capacity,
        'status': status.name,
        'targetMinPercent': targetMinPercent,
        'lastVerifiedBy': lastVerifiedBy,
        'lastVerifiedAt': lastVerifiedAt.toIso8601String(),
      };

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        count: json['count'] as int,
        capacity: json['capacity'] as int,
        status: StockStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => StockStatus.available,
        ),
        targetMinPercent: json['targetMinPercent'] as int? ?? 30,
        lastVerifiedBy: json['lastVerifiedBy'] as String? ?? 'Harriet A.',
        lastVerifiedAt: DateTime.parse(json['lastVerifiedAt'] as String),
      );
}
