import '../models/discreet_message.dart';
import '../services/mock_backend_store.dart';

abstract class IMessagingRepository {
  Future<List<DiscreetMessage>> getMessages(String voucherCode);
  Future<DiscreetMessage> sendMessage({
    required String voucherCode,
    required String message,
  });
}

class MessagingRepository implements IMessagingRepository {
  final MockBackendStore _store = MockBackendStore();

  @override
  Future<List<DiscreetMessage>> getMessages(String voucherCode) async {
    return _store.messages.where((m) => m.voucherCode == voucherCode).toList();
  }

  @override
  Future<DiscreetMessage> sendMessage({
    required String voucherCode,
    required String message,
  }) async {
    final msg = DiscreetMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      voucherCode: voucherCode,
      senderId: _store.currentUser.id,
      senderName: _store.currentUser.pseudonym,
      message: message,
      timestamp: DateTime.now(),
      isSeeker: true,
      isDelivered: true,
      isRead: true,
    );
    _store.messages.add(msg);
    return msg;
  }
}
