import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/app_user_state.dart';
import '../dashboard/projects_repository.dart';
import 'tasks_repository.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.projectId, required this.taskId, this.task});

  final String projectId;
  final String taskId;
  final Task? task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _repo = TasksRepository();
  final _projectsRepo = ProjectsRepository();
  final _syncRepo = SyncQueueRepository();

  Task? _task;
  List<TaskStatus> _statuses = [];
  List<TaskUpdateNote> _updates = [];
  String? _projectRole; // admin | member | viewer
  bool _loading = true;
  final _noteController = TextEditingController();
  bool _addingNote = false;

  bool get _canEditTask => _projectRole == 'admin' || _projectRole == 'member';
  bool get _canEditTaskFull => _projectRole == 'admin';

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    if (_task != null) _loading = false;
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final role = await _projectsRepo.getMyProjectAccess(widget.projectId);
    if (_task == null) {
      setState(() => _loading = true);
      final t = await _repo.getTask(widget.projectId, widget.taskId);
      if (mounted) setState(() { _task = t; _loading = false; });
    }
    final statuses = await _repo.listStatuses(widget.projectId);
    final updates = await _repo.listTaskUpdates(widget.projectId, widget.taskId);
    if (mounted) setState(() { _projectRole = role; _statuses = statuses; _updates = updates; });
  }

  Future<void> _addNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty || _addingNote) return;
    setState(() => _addingNote = true);
    try {
      final added = await _repo.addTaskUpdate(widget.projectId, widget.taskId, note);
      if (mounted) {
        setState(() { _updates = [added, ..._updates]; _addingNote = false; _noteController.clear(); });
        _showToast('Note added.');
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _addingNote = false);
        _showToast(e.response?.data is Map ? (e.response?.data as Map)['detail']?.toString() ?? 'Failed' : e.message ?? 'Failed');
      }
    } catch (e) {
      if (mounted) setState(() => _addingNote = false);
      _showToast('Failed: $e');
    }
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
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

  Future<void> _editTask() async {
    final task = _task;
    if (task == null || !_canEditTask) return;
    final canEditFull = _canEditTaskFull;
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');
    String? selectedStatusId = task.statusId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(canEditFull ? 'Edit task' : 'Update note & status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canEditFull) ...[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note / Description', border: OutlineInputBorder()),
                ),
                if (_statuses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatusId ?? (_statuses.isNotEmpty ? _statuses.first.id : null),
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: _statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setDialogState(() => selectedStatusId = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final title = canEditFull ? titleController.text.trim() : task.title;
    if (canEditFull && title.isEmpty) {
      _showToast('Title is required.');
      return;
    }
    final description = descController.text.trim().isEmpty ? null : descController.text.trim();
    try {
      final updated = await _repo.updateTask(
        widget.projectId,
        widget.taskId,
        title: canEditFull ? title : null,
        description: description,
        statusId: selectedStatusId,
      );
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        setState(() => _task = updated);
        _showToast('Task updated.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('task_update', {
          'project_id': widget.projectId,
          'task_id': widget.taskId,
          if (canEditFull) 'title': title,
          'description': description,
          'status_id': selectedStatusId,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          setState(() => _task = Task(
                id: task.id,
                projectId: task.projectId,
                title: title,
                description: description,
                statusId: selectedStatusId,
                assigneeId: task.assigneeId,
                createdBy: task.createdBy,
                dueAt: task.dueAt,
                createdAt: task.createdAt,
                updatedAt: task.updatedAt,
              ));
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final task = _task;
    if (task == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
        body: const Center(child: Text('Task not found')),
      );
    }
    final statusName = _statuses.where((s) => s.id == task.statusId).firstOrNull?.name ?? task.statusId ?? '—';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Task'),
        actions: _canEditTask ? [IconButton(icon: const Icon(Icons.edit), onPressed: _editTask)] : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag),
            title: const Text('Status'),
            subtitle: Text(statusName),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(task.description!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text('Activity log', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_updates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No updates yet.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          else
            ..._updates.map((u) {
              final isMe = context.read<AppUserState>().user?.id == u.authorId;
              final authorLabel = isMe ? 'You' : u.authorId.length > 8 ? '${u.authorId.substring(0, 8)}…' : u.authorId;
              final dt = u.createdAt != null ? DateTime.tryParse(u.createdAt!)?.toLocal() : null;
              final dateStr = dt != null ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}' : (u.createdAt ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$dateStr · $authorLabel', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(u.note, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            }),
          if (_canEditTask) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add a note…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _addingNote ? null : _addNote,
              child: Text(_addingNote ? 'Adding…' : 'Add note'),
            ),
          ],
        ],
      ),
    );
  }
}
