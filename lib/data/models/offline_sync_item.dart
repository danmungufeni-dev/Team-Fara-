enum SyncItemType {
  hubRegistration,
  disbursement,
  stockAudit,
  dignityIncident,
}

enum SyncItemStatus {
  pending,
  syncing,
  synced,
  conflict,
  failed,
}

class OfflineSyncItem {
  final String id;
  final String queueIdentifier;
  final SyncItemType type;
  final String title;
  final String description;
  final Map<String, dynamic> payload;
  final int payloadSizeBytes;
  final int attachedMediaCount;
  final String localHash;
  final int queuePosition;
  final SyncItemStatus status;
  final DateTime createdAt;
  final String? errorMessage;

  const OfflineSyncItem({
    required this.id,
    required this.queueIdentifier,
    required this.type,
    required this.title,
    required this.description,
    required this.payload,
    this.payloadSizeBytes = 2457600, // 2.4MB
    this.attachedMediaCount = 2,
    required this.localHash,
    required this.queuePosition,
    this.status = SyncItemStatus.pending,
    required this.createdAt,
    this.errorMessage,
  });

  OfflineSyncItem copyWith({
    SyncItemStatus? status,
    String? errorMessage,
  }) {
    return OfflineSyncItem(
      id: id,
      queueIdentifier: queueIdentifier,
      type: type,
      title: title,
      description: description,
      payload: payload,
      payloadSizeBytes: payloadSizeBytes,
      attachedMediaCount: attachedMediaCount,
      localHash: localHash,
      queuePosition: queuePosition,
      status: status ?? this.status,
      createdAt: createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'queueIdentifier': queueIdentifier,
        'type': type.name,
        'title': title,
        'description': description,
        'payload': payload,
        'payloadSizeBytes': payloadSizeBytes,
        'attachedMediaCount': attachedMediaCount,
        'localHash': localHash,
        'queuePosition': queuePosition,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory OfflineSyncItem.fromJson(Map<String, dynamic> json) =>
      OfflineSyncItem(
        id: json['id'] as String,
        queueIdentifier: json['queueIdentifier'] as String,
        type: SyncItemType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => SyncItemType.hubRegistration,
        ),
        title: json['title'] as String,
        description: json['description'] as String,
        payload: json['payload'] as Map<String, dynamic>? ?? {},
        payloadSizeBytes: json['payloadSizeBytes'] as int? ?? 1024,
        attachedMediaCount: json['attachedMediaCount'] as int? ?? 0,
        localHash: json['localHash'] as String? ?? 'e8f2...7c1a',
        queuePosition: json['queuePosition'] as int? ?? 1,
        status: SyncItemStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SyncItemStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        errorMessage: json['errorMessage'] as String?,
      );
}
