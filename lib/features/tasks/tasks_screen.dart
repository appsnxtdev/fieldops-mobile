import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../dashboard/projects_repository.dart';
import 'tasks_repository.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TasksRepository();
  final _projectsRepo = ProjectsRepository();
  final _syncRepo = SyncQueueRepository();

  List<TaskStatus> _statuses = [];
  List<Task> _tasks = [];
  String? _projectRole; // admin | member | viewer
  bool _loading = true;

  bool get _canCreateTask => _projectRole == 'admin' || _projectRole == 'member';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final role = await _projectsRepo.getMyProjectAccess(widget.projectId);
      final statuses = await _repo.listStatuses(widget.projectId);
      final tasks = await _repo.listTasks(widget.projectId);
      if (mounted) {
        setState(() {
          _projectRole = role;
          _statuses = statuses;
          _tasks = tasks;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _statuses = []; _tasks = []; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
  }

  String _statusName(String? statusId) {
    if (statusId == null) return '—';
    return _statuses.where((s) => s.id == statusId).firstOrNull?.name ?? statusId;
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepOrange.shade700,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    String? selectedStatusId = _statuses.isNotEmpty ? _statuses.first.id : null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                if (_statuses.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedStatusId,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: _statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setDialogState(() => selectedStatusId = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _showToast('Title is required.');
      return;
    }
    try {
      await _repo.createTask(widget.projectId, title: title, statusId: selectedStatusId);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        _showToast('Task added.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('task_create', {
          'project_id': widget.projectId,
          'title': title,
          if (selectedStatusId != null) 'status_id': selectedStatusId,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          _load();
        }
      } else {
        _showToast(e.response?.data is Map ? (e.response?.data as Map)['detail']?.toString() ?? 'Failed' : e.message ?? 'Failed');
      }
    } catch (e) {
      _showToast('Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/project/${widget.projectId}')),
        title: const Text('Tasks'),
      ),
      body: _loading && _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_statuses.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: _statuses.map((s) => Chip(label: Text(s.name))).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(_canCreateTask ? 'No tasks. Tap + to add.' : 'No tasks.'),
                      ),
                    )
                  else
                    ..._tasks.map((t) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text(_statusName(t.statusId)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/project/${widget.projectId}/tasks/${t.id}', extra: t),
                          ),
                        )),
                ],
              ),
            ),
      floatingActionButton: _canCreateTask
          ? FloatingActionButton(
              onPressed: _addTask,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
