import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../../data/models/distribution_point.dart';
import '../../data/models/request_voucher.dart';
import '../../data/models/discreet_message.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/mock_backend_store.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient? _client;
  bool _isInitialized = false;
  bool _isSimulationMode = true;

  // Local in-memory stream controllers for offline/mock realtime synchronization
  final StreamController<List<DistributionPoint>> _hubsStreamController =
      StreamController<List<DistributionPoint>>.broadcast();
  final StreamController<List<RequestVoucher>> _requestsStreamController =
      StreamController<List<RequestVoucher>>.broadcast();
  final StreamController<List<DiscreetMessage>> _messagesStreamController =
      StreamController<List<DiscreetMessage>>.broadcast();
  final StreamController<Map<String, dynamic>> _liveLocationsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<UserProfile?> _authStreamController =
      StreamController<UserProfile?>.broadcast();

  final MockBackendStore _mockStore = MockBackendStore();
  UserProfile? _currentSessionUser;

  bool get isInitialized => _isInitialized;
  bool get isSimulationMode => _isSimulationMode;
  bool get isLiveSupabase => _isInitialized && !_isSimulationMode && _client != null;
  SupabaseClient? get client => _client;

  /// Initializes Supabase with either explicit credentials, local storage,
  /// or compile-time environment variables.
  Future<void> init({String? url, String? anonKey}) async {
    final storedUrl = LocalStorage.getString(AppConstants.storageKeySupabaseUrl);
    const configuredUrl = String.fromEnvironment(AppConstants.envSupabaseUrl);
    final effectiveUrl = url ??
        (storedUrl?.isNotEmpty == true
            ? storedUrl!
            : (configuredUrl.isNotEmpty
                ? configuredUrl
                : AppConstants.defaultSupabaseUrl));

    final storedKey = LocalStorage.getString(AppConstants.storageKeySupabaseAnonKey);
    const publishableKey = String.fromEnvironment(AppConstants.envSupabasePublishableKey);
    const legacyAnonKey = String.fromEnvironment(AppConstants.envSupabaseAnonKey);
    final effectiveKey = anonKey ??
        (storedKey?.isNotEmpty == true
            ? storedKey!
            : (publishableKey.isNotEmpty ? publishableKey : legacyAnonKey));

    if (effectiveUrl.isNotEmpty && effectiveKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: effectiveUrl,
          anonKey: effectiveKey,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _client = Supabase.instance.client;
        _isInitialized = true;
        _isSimulationMode = false;
        debugPrint('⚡ [SupabaseService] Connected to live Supabase: $effectiveUrl');
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Live initialization fallback to offline simulation: $e');
        _isSimulationMode = true;
      }
    } else {
      debugPrint('ℹ️ [SupabaseService] No Supabase credentials supplied; running in Free Offline Realtime Simulation Mode.');
      _isSimulationMode = true;
    }

    _currentSessionUser = _mockStore.currentUser;
    _emitLocalHubs();
    _emitLocalRequests();
  }

  void _emitLocalHubs() {
    _hubsStreamController.add(List.unmodifiable(_mockStore.hubs));
  }

  void _emitLocalRequests() {
    _requestsStreamController.add(List.unmodifiable(_mockStore.vouchers));
  }

  // ==========================================
  // REALTIME AUTHENTICATION
  // ==========================================

  Stream<UserProfile?> get authStateChanges => _authStreamController.stream;

  UserProfile get currentUser => _currentSessionUser ?? _mockStore.currentUser;

  Future<UserProfile> signUp({
    required String email,
    required String password,
    String? pseudonym,
    UserRole role = UserRole.seeker,
  }) async {
    final pseudo = pseudonym?.trim().isNotEmpty == true
        ? pseudonym!.trim()
        : 'Confidential Seeker #${DateTime.now().millisecondsSinceEpoch % 1000}';

    if (isLiveSupabase) {
      try {
        final res = await _client!.auth.signUp(
          email: email,
          password: password,
          data: {
            'pseudonym': pseudo,
            'role': role.name,
          },
        );

        final user = UserProfile(
          id: res.user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
          pseudonym: pseudo,
          email: email,
          role: role,
          joinedDate: DateTime.now(),
          termsAccepted: true,
        );
        _currentSessionUser = user;
        _authStreamController.add(user);
        await SecureStorage.writeToken(AppConstants.storageKeyUserToken, res.session?.accessToken ?? 'sb_token');
        return user;
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Sign-up failed on live Supabase: $e');
        rethrow;
      }
    }

    // Local / Offline-first sign-up
    final user = UserProfile(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      pseudonym: pseudo,
      email: email,
      role: role,
      joinedDate: DateTime.now(),
      termsAccepted: true,
    );
    _currentSessionUser = user;
    _mockStore.currentUser = user;
    _authStreamController.add(user);
    await SecureStorage.writeToken(AppConstants.storageKeyUserToken, 'mock_jwt_${user.id}');
    return user;
  }

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isLiveSupabase) {
      try {
        final res = await _client!.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final meta = res.user?.userMetadata ?? {};
        final roleStr = meta['role'] as String? ?? 'seeker';
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => UserRole.seeker,
        );

        final user = UserProfile(
          id: res.user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
          pseudonym: (meta['pseudonym'] as String?) ?? 'Discreet User',
          email: email,
          role: role,
          joinedDate: DateTime.now(),
          termsAccepted: true,
        );
        _currentSessionUser = user;
        _authStreamController.add(user);
        await SecureStorage.writeToken(AppConstants.storageKeyUserToken, res.session?.accessToken ?? 'sb_token');
        return user;
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Sign-in failed on live Supabase: $e');
        rethrow;
      }
    }

    final user = _mockStore.currentUser.copyWith(
      email: email,
      pseudonym: _mockStore.currentUser.pseudonym.isNotEmpty
          ? _mockStore.currentUser.pseudonym
          : 'Discreet User',
    );
    _currentSessionUser = user;
    _mockStore.currentUser = user;
    _authStreamController.add(user);
    await SecureStorage.writeToken(AppConstants.storageKeyUserToken, 'mock_jwt_${user.id}');
    return user;
  }

  /// Dignity Anonymous Authentication (Zero PII, Instant Anonymous Session)
  Future<UserProfile> signInAnonymously({String? pseudonym}) async {
    final pseudo = pseudonym ?? 'Anonymous Dignity Seeker #${DateTime.now().millisecondsSinceEpoch % 1000}';

    if (isLiveSupabase) {
      try {
        final res = await _client!.auth.signInAnonymously(
          data: {'pseudonym': pseudo, 'role': 'seeker'},
        );
        final user = UserProfile(
          id: res.user?.id ?? 'anon_${DateTime.now().millisecondsSinceEpoch}',
          pseudonym: pseudo,
          email: 'anonymous@padcare.org',
          role: UserRole.seeker,
          incognitoMode: true,
          joinedDate: DateTime.now(),
          termsAccepted: true,
        );
        _currentSessionUser = user;
        _authStreamController.add(user);
        return user;
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Anonymous auth failed on live Supabase: $e');
        rethrow;
      }
    }

    final user = UserProfile(
      id: 'anon_${DateTime.now().millisecondsSinceEpoch}',
      pseudonym: pseudo,
      email: 'anonymous@padcare.org',
      role: UserRole.seeker,
      incognitoMode: true,
      joinedDate: DateTime.now(),
      termsAccepted: true,
    );
    _currentSessionUser = user;
    _mockStore.currentUser = user;
    _authStreamController.add(user);
    await SecureStorage.writeToken(AppConstants.storageKeyUserToken, 'anon_token_${user.id}');
    return user;
  }

  Future<void> signOut() async {
    if (isLiveSupabase) {
      try {
        await _client!.auth.signOut();
      } catch (_) {}
    }
    await SecureStorage.deleteToken(AppConstants.storageKeyUserToken);
    _currentSessionUser = null;
    _authStreamController.add(null);
  }

  // Fetch distribution points from Supabase when configured. In live mode,
  // backend errors are surfaced instead of being hidden by mock data.
  Future<List<DistributionPoint>> fetchDistributionPoints() async {
    if (!isLiveSupabase) {
      return List.unmodifiable(_mockStore.hubs);
    }
    final rows = await _client!.from('distribution_points').select();
    return rows
        .map((row) => DistributionPoint.fromJson(row))
        .toList(growable: false);
  }

  Future<DistributionPoint?> fetchDistributionPointById(String id) async {
    final points = await fetchDistributionPoints();
    for (final point in points) {
      if (point.id == id) return point;
    }
    return null;
  }

  // ==========================================
  // REALTIME DISTRIBUTION POINTS (HUBS)
  // ==========================================

  Stream<List<DistributionPoint>> streamDistributionPoints() {
    if (isLiveSupabase) {
      try {
        return _client!
            .from('distribution_points')
            .stream(primaryKey: ['id'])
            .map((dataList) {
          return dataList.map((map) => DistributionPoint.fromJson(map)).toList();
        });
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Stream error on distribution points: $e');
      }
    }
    late StreamController<List<DistributionPoint>> controller;
    StreamSubscription? sub;
    controller = StreamController<List<DistributionPoint>>.broadcast(
      onListen: () {
        controller.add(List.unmodifiable(_mockStore.hubs));
        sub = _hubsStreamController.stream.listen((hubs) {
          if (!controller.isClosed) controller.add(hubs);
        });
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  Future<void> upsertDistributionPoint(DistributionPoint point) async {
    if (isLiveSupabase) {
      try {
        await _client!.from('distribution_points').upsert(point.toJson());
        return;
      } catch (e) {
        debugPrint('⚠️ [SupabaseService] Live upsert failed: $e');
        rethrow;
      }
    }

    final index = _mockStore.hubs.indexWhere((h) => h.id == point.id);
    if (index >= 0) {
      _mockStore.hubs[index] = point;
    } else {
      _mockStore.hubs.insert(0, point);
    }
    _emitLocalHubs();
  }

  // ==========================================
  // REALTIME REQUEST VOUCHERS
  // ==========================================

  Stream<List<RequestVoucher>> streamRequests() {
    if (isLiveSupabase) {
      // Sensitive rows are not subscribed to directly. Fetch only the caller's
      // requests through the ownership-checking RPC.
      return Stream.fromFuture(listMyPickupRequests());
    }
    late StreamController<List<RequestVoucher>> controller;
    StreamSubscription? sub;
    controller = StreamController<List<RequestVoucher>>.broadcast(
      onListen: () {
        controller.add(List.unmodifiable(_mockStore.vouchers));
        sub = _requestsStreamController.stream.listen((vouchers) {
          if (!controller.isClosed) controller.add(vouchers);
        });
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  Future<RequestVoucher> createRequest(RequestVoucher voucher) async {
    if (isLiveSupabase) {
      final result = await _client!.rpc('create_pickup_request', params: {
        'p_hub_id': voucher.hubId,
        'p_allocation_summary': voucher.allocationSummary,
        'p_pickup_window': voucher.pickupWindow,
      });
      if (result is! Map) throw StateError('Invalid pickup request response');
      final created = RequestVoucher.fromJson(Map<String, dynamic>.from(result));
      _mockStore.vouchers.insert(0, created);
      _emitLocalRequests();
      return created;
    }
    _mockStore.vouchers.insert(0, voucher);
    _emitLocalRequests();
    return voucher;
  }

  Future<List<RequestVoucher>> listMyPickupRequests() async {
    if (!isLiveSupabase) return List.unmodifiable(_mockStore.vouchers);
    final result = await _client!.rpc('list_my_pickup_requests');
    if (result is! List) throw StateError('Invalid pickup request list response');
    return result.map((row) => RequestVoucher.fromJson(Map<String, dynamic>.from(row as Map))).toList(growable: false);
  }

  Future<bool> verifyPickupVoucher(String voucherCode) async {
    if (isLiveSupabase) {
      final result = await _client!.rpc('verify_pickup_voucher', params: {'p_voucher_code': voucherCode});
      return result == true;
    }
    final idx = _mockStore.vouchers.indexWhere((v) => v.voucherCode == voucherCode || v.pin == voucherCode);
    if (idx < 0) return false;
    final v = _mockStore.vouchers[idx];
    _mockStore.vouchers[idx] = RequestVoucher(
      id: v.id, voucherCode: v.voucherCode, hubId: v.hubId, hubName: v.hubName,
      allocationSummary: v.allocationSummary, status: VoucherStatus.collected,
      createdAt: v.createdAt, expiresAt: v.expiresAt, pickupWindow: v.pickupWindow, pin: v.pin);
    _emitLocalRequests();
    return true;
  }

  Future<void> updateRequestStatus(String voucherId, VoucherStatus status) async {
    if (isLiveSupabase) {
      throw UnsupportedError('Pickup status changes must use the authorized voucher verification RPC.');
    }

    final idx = _mockStore.vouchers.indexWhere((v) => v.id == voucherId);
    if (idx >= 0) {
      final v = _mockStore.vouchers[idx];
      _mockStore.vouchers[idx] = RequestVoucher(
        id: v.id,
        voucherCode: v.voucherCode,
        hubId: v.hubId,
        hubName: v.hubName,
        allocationSummary: v.allocationSummary,
        status: status,
        createdAt: v.createdAt,
        expiresAt: v.expiresAt,
        pickupWindow: v.pickupWindow,
        pin: v.pin,
      );
      _emitLocalRequests();
    }
  }

  // ==========================================
  // REALTIME DISCREET MESSAGING
  // ==========================================

  Stream<List<DiscreetMessage>> streamMessages({String? voucherCode}) {
    if (isLiveSupabase) {
      if (voucherCode == null || voucherCode.trim().isEmpty) {
        return Stream.error(ArgumentError('A pickup voucher is required to access messages.'));
      }
      return Stream.fromFuture(_client!.rpc('list_pickup_messages', params: {
        'p_voucher_code': voucherCode.trim(),
      }).then((result) {
        if (result is! List) throw StateError('Invalid messages response');
        return result.map((row) => DiscreetMessage.fromJson(Map<String, dynamic>.from(row as Map))).toList(growable: false);
      }));
    }

    return _messagesStreamController.stream.map((list) {
      if (voucherCode != null && voucherCode.isNotEmpty) {
        return list.where((m) => m.voucherCode == voucherCode).toList();
      }
      return list;
    });
  }

  Future<void> sendMessage(DiscreetMessage msg) async {
    if (isLiveSupabase) {
      await _client!.rpc('send_pickup_message', params: {
        'p_voucher_code': msg.voucherCode,
        'p_message': msg.message,
      });
      return;
    }

    _mockStore.messages.add(msg);
    _messagesStreamController.add(List.unmodifiable(_mockStore.messages));
  }

  // ==========================================
  // REALTIME VOLUNTEER & HUB LIVE TRACKING
  // ==========================================

  Stream<Map<String, dynamic>> streamLiveLocations() {
    return _liveLocationsController.stream;
  }

  void broadcastLocation({
    required String entityId,
    required double latitude,
    required double longitude,
    required String label,
    required String type, // 'volunteer', 'mobile_dispensary', 'user'
  }) {
    final payload = {
      'entityId': entityId,
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
      'type': type,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (isLiveSupabase) {
      // Unauthenticated broadcast channels bypass the database authorization model.
      // Use publishStaffLocation() with an assigned hub instead.
      throw UnsupportedError('Live location publishing requires an authorized hub assignment.');
    }

    _liveLocationsController.add(payload);
  }

  Future<void> publishStaffLocation({
    required String hubId,
    required double latitude,
    required double longitude,
    required String label,
    required String type,
  }) async {
    if (!isLiveSupabase) throw StateError('Supabase is not configured.');
    await _client!.rpc('publish_staff_location', params: {
      'p_hub_id': hubId,
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_label': label,
      'p_type': type,
    });
  }

  Future<List<Map<String, dynamic>>> fetchStaffLocations(String hubId) async {
    if (!isLiveSupabase) return const [];
    final result = await _client!.rpc('list_staff_locations', params: {'p_hub_id': hubId});
    if (result is! List) throw StateError('Invalid live-location response');
    return result.map((row) => Map<String, dynamic>.from(row as Map)).toList(growable: false);
  }

  /// Configure credentials dynamically from the Settings UI
  Future<bool> updateCredentials({
    required String url,
    required String anonKey,
  }) async {
    await LocalStorage.setString(AppConstants.storageKeySupabaseUrl, url.trim());
    await LocalStorage.setString(AppConstants.storageKeySupabaseAnonKey, anonKey.trim());
    await init(url: url.trim(), anonKey: anonKey.trim());
    return isLiveSupabase;
  }
}
