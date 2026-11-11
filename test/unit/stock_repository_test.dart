import 'package:flutter_test/flutter_test.dart';
import 'package:padcare/data/models/stock_item.dart';
import 'package:padcare/data/repositories/stock_repository.dart';

void main() {
  group('StockRepository Tests', () {
    test('Adjusting stock within capacity updates count', () async {
      final repo = StockRepository();
      final items = await repo.getStockItems();
      final item = items.first;
      final initialCount = item.count;

      final updated = await repo.adjustStock(item.id, 5);
      expect(updated.count, initialCount + 5);
    });

    test('Stock count cannot drop below zero', () async {
      final repo = StockRepository();
      final items = await repo.getStockItems();
      final item = items.first;

      final updated = await repo.adjustStock(item.id, -9999);
      expect(updated.count, 0);
      expect(updated.status, StockStatus.outOfStock);
    });

    test('Recording NGO intake increases stock quantity', () async {
      final repo = StockRepository();
      final items = await repo.getStockItems();
      final first = items.first;
      final countBefore = first.count;

      await repo.recordIntake(
        itemName: first.name,
        quantity: 25,
        batchNumber: 'TEST-BATCH-101',
        sourceNgo: 'MOH Uganda',
      );

      final itemsAfter = await repo.getStockItems();
      final updated = itemsAfter.firstWhere((i) => i.id == first.id);
      expect(updated.count, countBefore + 25);
    });
  });
}
