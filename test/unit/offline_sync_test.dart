import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/data/models/conflict_model.dart';
import 'package:padcare/data/models/offline_sync_item.dart';
import 'package:padcare/data/repositories/sync_repository.dart';

void main() {
  group('Offline Synchronization & Conflict Resolution Tests', () {
    test('Enqueueing item adds it to pending queue', () async {
      final repo = SyncRepository();
      final initialQueue = await repo.getQueue();
      final initialLength = initialQueue.length;

      final newItem = await repo.enqueueItem(
        type: SyncItemType.disbursement,
        title: 'Disbursement: Kisenyi Health Center IV',
        description: 'Offline voucher token verified.',
        payload: {'code': 'PAD-749', 'units': 2},
      );

      expect(newItem.status, SyncItemStatus.pending);
      expect(newItem.queuePosition, initialLength + 1);

      final updatedQueue = await repo.getQueue();
      expect(updatedQueue.length, initialLength + 1);
    });

    test('SyncAll transitions pending items to synced', () async {
      final repo = SyncRepository();
      await repo.syncAll();
      final queue = await repo.getQueue();
      for (final item in queue) {
        expect(item.status, SyncItemStatus.synced);
      }
    });

    test('CRDT Conflict resolution marks conflict as resolved', () async {
      final repo = SyncRepository();
      final conflict = await repo.getActiveConflict();
      expect(conflict.isResolved, false);

      await repo.resolveConflict(ResolutionStrategy.smartMerge);
      final resolved = await repo.getActiveConflict();
      expect(resolved.isResolved, true);
      expect(resolved.activeStrategy, ResolutionStrategy.smartMerge);
    });
  });
}
