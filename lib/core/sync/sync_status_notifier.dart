import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../storage/sync_queue_repository.dart';

/// Exposes pending sync count and connectivity for UI.
/// Connectivity is driven by the connectivity stream for reliability; refresh() updates pending count.
class SyncStatusNotifier extends ChangeNotifier {
  SyncStatusNotifier({
    SyncQueueRepository? repo,
    Connectivity? connectivity,
  })  : _repo = repo ?? SyncQueueRepository(),
        _connectivity = connectivity ?? Connectivity();

  final SyncQueueRepository _repo;
  final Connectivity _connectivity;
  StreamSubscription<dynamic>? _connectivitySub;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;
  bool get isSynced => _pendingCount == 0;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  static bool _resultsToOnline(List<ConnectivityResult> list) {
    return list.any((r) => r != ConnectivityResult.none);
  }

  /// Call once (e.g. from app) to listen to connectivity. Uses stream for accurate state.
  void startConnectivityListening() {
    if (_connectivitySub != null) return;
    _connectivity.checkConnectivity().then((result) {
      final list = result is List
          ? List<ConnectivityResult>.from(result as List)
          : <ConnectivityResult>[result];
      if (_isOnline != _resultsToOnline(list)) {
        _isOnline = _resultsToOnline(list);
        notifyListeners();
      }
    });
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      final list = result is List
          ? List<ConnectivityResult>.from(result as List)
          : <ConnectivityResult>[result as ConnectivityResult];
      final online = _resultsToOnline(list);
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    final result = await _connectivity.checkConnectivity();
    final list = result is List
        ? List<ConnectivityResult>.from(result as List)
        : <ConnectivityResult>[result];
    final online = _resultsToOnline(list);
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
    final count = await _repo.pendingCount();
    if (_pendingCount != count) {
      _pendingCount = count;
      notifyListeners();
    }
  }
}
