import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/storage/app_database.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';
import '../../core/sync/sync_worker.dart';

/// Shows all pending (not yet synced) items so supervisors can see what the app has not committed.
class PendingSyncScreen extends StatefulWidget {
  const PendingSyncScreen({super.key});

  @override
  State<PendingSyncScreen> createState() => _PendingSyncScreenState();
}

class _PendingSyncScreenState extends State<PendingSyncScreen> {
  final _repo = SyncQueueRepository();
  List<SyncQueue> _pending = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
    _triggerSyncIfOnline();
  }

  Future<List<SyncQueue>> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getPending();
    if (mounted) {
      setState(() {
        _pending = list;
        _loading = false;
      });
    }
    return list;
  }

  Future<void> _triggerSyncIfOnline() async {
    if (!mounted) return;
    final statusNotifier = context.read<SyncStatusNotifier>();
    final syncWorker = context.read<SyncWorker>();
    if (!statusNotifier.isOnline) return;
    if (!mounted) return;
    setState(() => _syncing = true);
    await syncWorker.run();
    if (!mounted) return;
    await statusNotifier.refresh();
    if (mounted) {
      setState(() => _syncing = false);
      _load();
    }
  }

  Future<void> _syncNow() async {
    if (!mounted) return;
    final statusNotifier = context.read<SyncStatusNotifier>();
    final syncWorker = context.read<SyncWorker>();
    if (!statusNotifier.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You\'re offline. Sync will run when connected.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() => _syncing = true);
    await syncWorker.run();
    if (!mounted) return;
    await statusNotifier.refresh();
    if (mounted) {
      setState(() => _syncing = false);
      final stillPending = await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stillPending.isEmpty
                  ? 'All pending items synced.'
                  : 'Sync attempted. ${stillPending.length} still pending.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static String _describe(SyncQueue item) {
    try {
      final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>?;
      if (payload == null) return item.kind;
      switch (item.kind) {
        case 'expense_credit':
          final amount = (payload['amount'] as num?)?.toDouble();
          return 'Add money ${amount != null ? '₹${amount.toStringAsFixed(0)}' : ''}';
        case 'expense_debit':
          final amount = (payload['amount'] as num?)?.toDouble();
          return 'Spend ${amount != null ? '₹${amount.toStringAsFixed(0)}' : ''}';
        case 'attendance_check_in':
          return 'Check-in (${payload['date'] ?? ''})';
        case 'attendance_check_out':
          return 'Check-out (${payload['date'] ?? ''})';
        case 'daily_report_note':
          final content = payload['content'] as String?;
          return 'Note: ${content != null && content.length > 40 ? '${content.substring(0, 40)}…' : content ?? ''}';
        case 'daily_report_photo':
          return 'Photo (${payload['report_date'] ?? ''})';
        case 'task_create':
          return 'Task: ${payload['title'] ?? ''}';
        case 'task_update':
          return 'Update task: ${payload['title'] ?? payload['task_id'] ?? ''}';
        case 'material_ledger_entry':
          final type = payload['type'] as String?;
          final qty = (payload['quantity'] as num?)?.toDouble();
          return 'Material $type ${qty ?? ''}';
        default:
          return item.kind;
      }
    } catch (_) {
      return item.kind;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Pending sync'),
        actions: [
            Consumer<SyncStatusNotifier>(
              builder: (context, sync, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: _syncing ? null : () => _syncNow(),
                  icon: _syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Sync now'),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _load();
                await _triggerSyncIfOnline();
              },
              child: _pending.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.cloud_done,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nothing pending',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All your offline changes have been synced to the cloud.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Changes made while offline will appear here until they are synced.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      itemCount: _pending.length,
                      itemBuilder: (context, index) {
                        final item = _pending[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.cloud_off,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(_describe(item)),
                            subtitle: Text(
                              '${item.kind} · ${_formatDate(item.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  static String _formatDate(DateTime d) {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
