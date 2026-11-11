import '../models/offline_sync_item.dart';
import '../models/conflict_model.dart';
import '../services/mock_backend_store.dart';

abstract class ISyncRepository {
  Future<List<OfflineSyncItem>> getQueue();
  Future<OfflineSyncItem> enqueueItem({
    required SyncItemType type,
    required String title,
    required String description,
    required Map<String, dynamic> payload,
  });
  Future<void> syncAll();
  Future<SyncConflict> getActiveConflict();
  Future<void> resolveConflict(ResolutionStrategy strategy);
}

class SyncRepository implements ISyncRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<OfflineSyncItem>> getQueue() async {
    return _store.offlineQueue;
  }

  @override
  Future<OfflineSyncItem> enqueueItem({
    required SyncItemType type,
    required String title,
    required String description,
    required Map<String, dynamic> payload,
  }) async {
    final newItem = OfflineSyncItem(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
      queueIdentifier: '#OFFLINE-SYNC-${1000 + _store.offlineQueue.length}',
      type: type,
      title: title,
      description: description,
      payload: payload,
      payloadSizeBytes: 1024 * 1024 * 2, // 2MB
      attachedMediaCount: 2,
      localHash: 'hash_${DateTime.now().millisecondsSinceEpoch}',
      queuePosition: _store.offlineQueue.length + 1,
      status: SyncItemStatus.pending,
      createdAt: DateTime.now(),
    );
    _store.offlineQueue.add(newItem);
    return newItem;
  }

  @override
  Future<void> syncAll() async {
    for (int i = 0; i < _store.offlineQueue.length; i++) {
      _store.offlineQueue[i] = _store.offlineQueue[i].copyWith(
        status: SyncItemStatus.synced,
      );
    }
  }

  @override
  Future<SyncConflict> getActiveConflict() async {
    return _store.activeConflict;
  }

  @override
  Future<void> resolveConflict(ResolutionStrategy strategy) async {
    _store.activeConflict = _store.activeConflict.copyWith(
      activeStrategy: strategy,
      isResolved: true,
    );
  }
}
