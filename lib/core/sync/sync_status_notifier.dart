import 'package:flutter/foundation.dart';

import '../storage/sync_queue_repository.dart';

/// Exposes pending sync count for UI ("Synced" when 0, "N pending" when > 0).
class SyncStatusNotifier extends ChangeNotifier {
  SyncStatusNotifier({SyncQueueRepository? repo}) : _repo = repo ?? SyncQueueRepository();

  final SyncQueueRepository _repo;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;
  bool get isSynced => _pendingCount == 0;

  Future<void> refresh() async {
    final count = await _repo.pendingCount();
    if (_pendingCount != count) {
      _pendingCount = count;
      notifyListeners();
    }
  }
}
