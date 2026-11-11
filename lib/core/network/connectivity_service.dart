import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStateStatus {
  online,
  offline,
  cellularEdge,
}

class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<ConnectionStateStatus> _controller =
      StreamController<ConnectionStateStatus>.broadcast();

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _connectivity.onConnectivityChanged.listen(_handleConnectivityList);
  }

  Stream<ConnectionStateStatus> get statusStream => _controller.stream;

  void _handleConnectivityList(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _controller.add(ConnectionStateStatus.offline);
    } else if (results.contains(ConnectivityResult.mobile)) {
      _controller.add(ConnectionStateStatus.cellularEdge);
    } else {
      _controller.add(ConnectionStateStatus.online);
    }
  }

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  void dispose() {
    _controller.close();
  }
}
