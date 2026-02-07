import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../storage/sync_queue_repository.dart';

/// Processes pending sync queue when online. Register handlers per kind (e.g. expense_credit in Phase 5).
class SyncWorker {
  SyncWorker({
    SyncQueueRepository? repo,
    Connectivity? connectivity,
    Map<String, Future<bool> Function(Map<String, dynamic> payload)>? handlers,
  })  : _repo = repo ?? SyncQueueRepository(),
        _connectivity = connectivity ?? Connectivity(),
        _handlers = Map<String, Future<bool> Function(Map<String, dynamic> payload)>.from(handlers ?? {});

  final SyncQueueRepository _repo;
  final Connectivity _connectivity;
  final Map<String, Future<bool> Function(Map<String, dynamic> payload)> _handlers;

  void registerHandler(String kind, Future<bool> Function(Map<String, dynamic> payload) handler) {
    _handlers[kind] = handler;
  }

  /// Call when app has connectivity; processes pending items in order. Stops on first 4xx or unknown kind.
  Future<void> run() async {
    final result = await _connectivity.checkConnectivity();
    final list = result is List
        ? List<ConnectivityResult>.from(result as List)
        : <ConnectivityResult>[result];
    final isOnline = list.any((r) => r != ConnectivityResult.none);
    if (!isOnline) {
      return;
    }

    final pending = await _repo.getPending();
    for (final item in pending) {
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final handler = _handlers[item.kind];
      if (handler == null) {
        break;
      }
      bool success = false;
      try {
        success = await handler(payload);
      } catch (_) {
        break;
      }
      if (success) {
        await _repo.markSynced(item.id);
      } else {
        break;
      }
    }
  }
}
