import '../models/distribution_point.dart';
import '../services/mock_backend_store.dart';

abstract class IDistributionPointRepository {
  Future<List<DistributionPoint>> getHubs({String? query, String? city});
  Future<DistributionPoint?> getHubById(String id);
  Future<void> addHub(DistributionPoint hub);
  Future<List<DistributionPoint>> getSavedHubs();
  Future<void> toggleSaveHub(String hubId);
}

class DistributionPointRepository implements IDistributionPointRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<DistributionPoint>> getHubs({String? query, String? city}) async {
    List<DistributionPoint> list = _store.hubs;
    if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
      list = list.where((h) => h.city.toLowerCase() == city.toLowerCase()).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.category.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<DistributionPoint?> getHubById(String id) async {
    try {
      return _store.hubs.firstWhere((h) => h.id == id);
    } catch (_) {
      return _store.hubs.isNotEmpty ? _store.hubs.first : null;
    }
  }

  @override
  Future<void> addHub(DistributionPoint hub) async {
    _store.hubs.insert(0, hub);
  }

  @override
  Future<List<DistributionPoint>> getSavedHubs() async {
    final savedIds = _store.currentUser.savedHubIds;
    return _store.hubs.where((h) => savedIds.contains(h.id)).toList();
  }

  @override
  Future<void> toggleSaveHub(String hubId) async {
    final list = List<String>.from(_store.currentUser.savedHubIds);
    if (list.contains(hubId)) {
      list.remove(hubId);
    } else {
      list.add(hubId);
    }
    _store.currentUser = _store.currentUser.copyWith(savedHubIds: list);
  }
}
