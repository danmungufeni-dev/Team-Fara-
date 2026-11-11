import '../models/stock_item.dart';
import '../services/mock_backend_store.dart';

abstract class IStockRepository {
  Future<List<StockItem>> getStockItems();
  Future<StockItem> adjustStock(String id, int delta);
  Future<StockItem> setStatus(String id, StockStatus status);
  Future<void> recordIntake({
    required String itemName,
    required int quantity,
    required String batchNumber,
    required String sourceNgo,
  });
}

class StockRepository implements IStockRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<StockItem>> getStockItems() async {
    return _store.stockItems;
  }

  @override
  Future<StockItem> adjustStock(String id, int delta) async {
    final idx = _store.stockItems.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      final current = _store.stockItems[idx];
      final newCount = (current.count + delta).clamp(0, current.capacity);
      final updated = current.copyWith(count: newCount);
      _store.stockItems[idx] = updated;
      return updated;
    }
    throw Exception('Stock item not found: $id');
  }

  @override
  Future<StockItem> setStatus(String id, StockStatus status) async {
    final idx = _store.stockItems.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      final updated = _store.stockItems[idx].copyWith(status: status);
      _store.stockItems[idx] = updated;
      return updated;
    }
    throw Exception('Stock item not found: $id');
  }

  @override
  Future<void> recordIntake({
    required String itemName,
    required int quantity,
    required String batchNumber,
    required String sourceNgo,
  }) async {
    final idx = _store.stockItems.indexWhere(
      (s) => s.name.toLowerCase().contains(itemName.toLowerCase()),
    );
    if (idx >= 0) {
      final current = _store.stockItems[idx];
      _store.stockItems[idx] = current.copyWith(count: current.count + quantity);
    }
  }
}
