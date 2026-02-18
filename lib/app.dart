import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/storage/sync_queue_repository.dart';
import 'core/sync/sync_status_notifier.dart';
import 'core/sync/sync_worker.dart';
import 'core/theme/app_theme.dart';
import 'features/attendance/attendance_repository.dart';
import 'features/auth/app_user_state.dart';
import 'features/daily_report/daily_report_repository.dart';
import 'features/expense/expense_repository.dart';
import 'features/materials/materials_repository.dart';
import 'features/tasks/tasks_repository.dart';

/// Root app widget.
class App extends StatelessWidget {
  const App({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final syncRepo = SyncQueueRepository();
    final syncWorker = SyncWorker(repo: syncRepo);
    final syncStatus = SyncStatusNotifier(repo: syncRepo);
    syncStatus.startConnectivityListening();
    _registerExpenseSyncHandlers(syncWorker);
    _registerAttendanceSyncHandlers(syncWorker);
    _registerDailyReportSyncHandlers(syncWorker);
    _registerTasksSyncHandlers(syncWorker);
    _registerMaterialsSyncHandlers(syncWorker);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppUserState()),
        ChangeNotifierProvider.value(value: syncStatus),
        Provider<SyncWorker>.value(value: syncWorker),
      ],
      child: _SyncTriggerWidget(
        syncWorker: syncWorker,
        syncStatus: syncStatus,
        child: MaterialApp.router(
          title: 'FieldOps',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          routerConfig: router,
        ),
      ),
    );
  }
}

/// Runs sync on app resume and when connectivity becomes online; refreshes sync status.
class _SyncTriggerWidget extends StatefulWidget {
  const _SyncTriggerWidget({
    required this.syncWorker,
    required this.syncStatus,
    required this.child,
  });

  final SyncWorker syncWorker;
  final SyncStatusNotifier syncStatus;
  final Widget child;

  @override
  State<_SyncTriggerWidget> createState() => _SyncTriggerWidgetState();
}

class _SyncTriggerWidgetState extends State<_SyncTriggerWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runSync();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) => _runSync());
    _dailyTimer = Timer.periodic(const Duration(hours: 24), (_) async {
      if (await widget.syncWorker.isOnline) _runSync();
    });
    _pendingSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await widget.syncStatus.refresh();
      if (widget.syncStatus.isOnline && widget.syncStatus.pendingCount > 0) {
        await _runSync();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    _dailyTimer?.cancel();
    _pendingSyncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _runSync();
  }

  final _connectivity = Connectivity();
  dynamic _connectivitySubscription;
  Timer? _dailyTimer;
  Timer? _pendingSyncTimer;

  Future<void> _runSync() async {
    await widget.syncWorker.run();
    await widget.syncStatus.refresh();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void _registerExpenseSyncHandlers(SyncWorker syncWorker) {
  final repo = ExpenseRepository();
  syncWorker.registerHandler('expense_credit', (payload) async {
    final projectId = payload['project_id'] as String;
    final amount = (payload['amount'] as num).toDouble();
    final notes = payload['notes'] as String?;
    await repo.addCredit(projectId, amount, notes: notes);
    return true;
  });
  syncWorker.registerHandler('expense_debit', (payload) async {
    final projectId = payload['project_id'] as String;
    final amount = (payload['amount'] as num).toDouble();
    final notes = payload['notes'] as String?;
    final receiptPath = payload['receipt_path'] as String?;
    if (receiptPath == null || !File(receiptPath).existsSync()) return false;
    await repo.addDebit(projectId, amount, receiptPath, notes: notes);
    return true;
  });
}

void _registerAttendanceSyncHandlers(SyncWorker syncWorker) {
  final repo = AttendanceRepository();
  syncWorker.registerHandler('attendance_check_in', (payload) async {
    final projectId = payload['project_id'] as String;
    final date = payload['date'] as String;
    final lat = (payload['lat'] as num).toDouble();
    final lng = (payload['lng'] as num).toDouble();
    final selfiePath = payload['selfie_path'] as String?;
    if (selfiePath == null || !File(selfiePath).existsSync()) return false;
    await repo.checkIn(projectId, date, lat, lng, selfiePath);
    return true;
  });
  syncWorker.registerHandler('attendance_check_out', (payload) async {
    final projectId = payload['project_id'] as String;
    final date = payload['date'] as String;
    final lat = (payload['lat'] as num).toDouble();
    final lng = (payload['lng'] as num).toDouble();
    final selfiePath = payload['selfie_path'] as String?;
    if (selfiePath == null || !File(selfiePath).existsSync()) return false;
    await repo.checkOut(projectId, date, lat, lng, selfiePath);
    return true;
  });
}

void _registerDailyReportSyncHandlers(SyncWorker syncWorker) {
  final repo = DailyReportRepository();
  syncWorker.registerHandler('daily_report_note', (payload) async {
    final projectId = payload['project_id'] as String;
    final reportDate = payload['report_date'] as String;
    final content = payload['content'] as String;
    final sortOrder = (payload['sort_order'] as num?)?.toInt() ?? 0;
    await repo.addNote(projectId, reportDate, content, sortOrder: sortOrder);
    return true;
  });
  syncWorker.registerHandler('daily_report_photo', (payload) async {
    final projectId = payload['project_id'] as String;
    final reportDate = payload['report_date'] as String;
    final photoPath = payload['photo_path'] as String?;
    final sortOrder = (payload['sort_order'] as num?)?.toInt() ?? 0;
    if (photoPath == null || !File(photoPath).existsSync()) return false;
    await repo.addPhoto(projectId, reportDate, photoPath, sortOrder: sortOrder);
    return true;
  });
}

void _registerTasksSyncHandlers(SyncWorker syncWorker) {
  final repo = TasksRepository();
  syncWorker.registerHandler('task_create', (payload) async {
    final projectId = payload['project_id'] as String;
    final title = payload['title'] as String;
    final statusId = payload['status_id'] as String?;
    await repo.createTask(projectId, title: title, statusId: statusId);
    return true;
  });
  syncWorker.registerHandler('task_update', (payload) async {
    final projectId = payload['project_id'] as String;
    final taskId = payload['task_id'] as String;
    final title = payload['title'] as String?;
    final description = payload['description'] as String?;
    final statusId = payload['status_id'] as String?;
    await repo.updateTask(projectId, taskId, title: title, description: description, statusId: statusId);
    return true;
  });
}

void _registerMaterialsSyncHandlers(SyncWorker syncWorker) {
  final repo = MaterialsRepository();
  syncWorker.registerHandler('material_ledger_entry', (payload) async {
    final projectId = payload['project_id'] as String;
    final materialId = payload['material_id'] as String;
    final type = payload['type'] as String;
    final quantity = (payload['quantity'] as num).toDouble();
    final notes = payload['notes'] as String?;
    await repo.addLedgerEntry(projectId, materialId, type: type, quantity: quantity, notes: notes);
    return true;
  });
}
