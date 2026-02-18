import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../storage/sync_queue_repository.dart';
import 'pull_service.dart';

/// Processes pending sync queue when online; then runs full pull. Register handlers per kind.
class SyncWorker {
  SyncWorker({
    SyncQueueRepository? repo,
    PullService? pullService,
    Connectivity? connectivity,
    Map<String, Future<bool> Function(Map<String, dynamic> payload)>? handlers,
  })  : _repo = repo ?? SyncQueueRepository(),
        _pullService = pullService ?? PullService(),
        _connectivity = connectivity ?? Connectivity(),
        _handlers = Map<String, Future<bool> Function(Map<String, dynamic> payload)>.from(handlers ?? {});

  final SyncQueueRepository _repo;
  final PullService _pullService;
  final Connectivity _connectivity;
  final Map<String, Future<bool> Function(Map<String, dynamic> payload)> _handlers;

  void registerHandler(String kind, Future<bool> Function(Map<String, dynamic> payload) handler) {
    _handlers[kind] = handler;
  }

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    final list = result is List
        ? List<ConnectivityResult>.from(result as List)
        : <ConnectivityResult>[result];
    return list.any((r) => r != ConnectivityResult.none);
  }

  /// Push pending queue then full pull when online.
  Future<void> run() async {
    if (!await isOnline) return;

    final pending = await _repo.getPending();
    for (final item in pending) {
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final handler = _handlers[item.kind];
      if (handler == null) break;
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

    try {
      await _pullService.runFullPull();
    } catch (_) {}
  }
}
