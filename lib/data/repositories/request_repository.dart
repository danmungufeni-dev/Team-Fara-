import 'dart:math';
import '../models/request_voucher.dart';
import '../services/mock_backend_store.dart';

abstract class IRequestRepository {
  Future<List<RequestVoucher>> getVouchers();
  Future<RequestVoucher?> getActiveVoucher();
  Future<RequestVoucher> createDiscreetRequest({
    required String hubId,
    required String hubName,
    required String allocationSummary,
    required String pickupWindow,
  });
  Future<bool> verifyAndDisburseVoucher(String pinOrCode);
}

class RequestRepository implements IRequestRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<RequestVoucher>> getVouchers() async {
    return _store.vouchers;
  }

  @override
  Future<RequestVoucher?> getActiveVoucher() async {
    try {
      return _store.vouchers.firstWhere((v) => !v.isExpired);
    } catch (_) {
      return _store.vouchers.isNotEmpty ? _store.vouchers.first : null;
    }
  }

  @override
  Future<RequestVoucher> createDiscreetRequest({
    required String hubId,
    required String hubName,
    required String allocationSummary,
    required String pickupWindow,
  }) async {
    final rand = Random();
    final codeNum = 100 + rand.nextInt(900);
    final voucherCode = 'PAD-$codeNum';

    final newVoucher = RequestVoucher(
      id: 'voucher_${DateTime.now().millisecondsSinceEpoch}',
      voucherCode: voucherCode,
      hubId: hubId,
      hubName: hubName,
      allocationSummary: allocationSummary,
      status: VoucherStatus.readyForPickup,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      pickupWindow: pickupWindow,
      pin: '$codeNum',
    );

    _store.vouchers.insert(0, newVoucher);
    _store.currentUser = _store.currentUser.copyWith(
      activeRequestsCount: _store.currentUser.activeRequestsCount + 1,
    );
    return newVoucher;
  }

  @override
  Future<bool> verifyAndDisburseVoucher(String pinOrCode) async {
    final clean = pinOrCode.trim().toUpperCase();
    final index = _store.vouchers.indexWhere(
      (v) => v.voucherCode == clean || v.pin == clean || clean.contains(v.pin),
    );
    if (index >= 0) {
      final v = _store.vouchers[index];
      _store.vouchers[index] = RequestVoucher(
        id: v.id,
        voucherCode: v.voucherCode,
        hubId: v.hubId,
        hubName: v.hubName,
        allocationSummary: v.allocationSummary,
        status: VoucherStatus.collected,
        createdAt: v.createdAt,
        expiresAt: v.expiresAt,
        pickupWindow: v.pickupWindow,
        pin: v.pin,
      );
      _store.currentUser = _store.currentUser.copyWith(
        safelyCollectedCount: _store.currentUser.safelyCollectedCount + 1,
      );
      return true;
    }
    return false;
  }
}
