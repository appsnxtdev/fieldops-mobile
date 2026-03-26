import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/app_user_state.dart';
import '../dashboard/projects_repository.dart';
import 'tasks_repository.dart';
import '../../core/errors/user_facing_messages.dart';
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
      final t = await _repo.getTask(widget.projectId, widget.taskId);
      if (mounted) setState(() => _task = t);
    }
    final statuses = await _repo.listStatuses(widget.projectId);
    final updates = await _repo.listTaskUpdates(widget.projectId, widget.taskId);
    if (mounted) {
      setState(() {
        _projectRole = role;
        _statuses = statuses;
        _updates = updates;
        _loading = false;
      });
    }
  }

  Future<void> _addNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty || _addingNote) return;
    setState(() => _addingNote = true);
    try {
      final added = await _repo.addTaskUpdate(widget.projectId, widget.taskId, note);
      if (mounted) {
        setState(() {
          _updates = [added, ..._updates];
          _addingNote = false;
          _noteController.clear();
        });
        _showToast('Note added.');
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _addingNote = false);
        _showToast(userFacingMessage(e, context: 'Add note'));
      }
    } catch (e) {
      if (mounted) setState(() => _addingNote = false);
      _showToast(userFacingMessage(e, context: 'Add note'));
    }
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
  }

  static String _formatDueAt(String? dueAt) {
    if (dueAt == null || dueAt.isEmpty) return '—';
    try {
      final dt = DateTime.parse(dueAt);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dueAt;
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// Admin-only: full edit dialog (title, status).
  Future<void> _editTaskAsAdmin() async {
    final task = _task;
    if (task == null || !_canEditTaskFull) return;
    final titleController = TextEditingController(text: task.title);
    String? selectedStatusId = task.statusId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
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
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _showToast('Title is required.');
      return;
    }
    try {
      final updated = await _repo.updateTask(
        widget.projectId,
        widget.taskId,
        title: title,
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
          'title': title,
          'status_id': selectedStatusId,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          setState(() => _task = Task(
                id: task.id,
                projectId: task.projectId,
                title: title,
                description: task.description,
                statusId: selectedStatusId,
                assigneeId: task.assigneeId,
                assigneeName: task.assigneeName,
                createdBy: task.createdBy,
                dueAt: task.dueAt,
                createdAt: task.createdAt,
                updatedAt: task.updatedAt,
              ));
        }
      } else {
        _showToast(userFacingMessage(e, context: 'Update task'));
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Update task'));
    }
  }

  /// Member: status-only update dialog.
  Future<void> _updateStatusAsMember() async {
    final task = _task;
    if (task == null || !_canEditTask) return;
    String? selectedStatusId = task.statusId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Update status'),
          content: _statuses.isEmpty
              ? const Text('No statuses available.')
              : DropdownButtonFormField<String>(
                  value: selectedStatusId ?? (_statuses.isNotEmpty ? _statuses.first.id : null),
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: _statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedStatusId = v),
                ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final updated = await _repo.updateTask(
        widget.projectId,
        widget.taskId,
        statusId: selectedStatusId,
      );
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        setState(() => _task = updated);
        _showToast('Status updated.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('task_update', {
          'project_id': widget.projectId,
          'task_id': widget.taskId,
          'status_id': selectedStatusId,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          setState(() => _task = Task(
                id: task.id,
                projectId: task.projectId,
                title: task.title,
                description: task.description,
                statusId: selectedStatusId,
                assigneeId: task.assigneeId,
                assigneeName: task.assigneeName,
                createdBy: task.createdBy,
                dueAt: task.dueAt,
                createdAt: task.createdAt,
                updatedAt: task.updatedAt,
              ));
        }
      } else {
        _showToast(userFacingMessage(e, context: 'Update status'));
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Update status'));
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
    final statusName = _statuses.where((s) => s.id == task.statusId).firstOrNull?.name ?? '—';
    final currentUserId = context.read<AppUserState>().user?.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text(task.title, overflow: TextOverflow.ellipsis),
        actions: _canEditTaskFull
            ? [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _editTaskAsAdmin, tooltip: 'Edit task')]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Add a note (prominent, at top) ──────────────────────────
          if (_canEditTask) ...[
            Text('Add note', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment or update…',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _addingNote ? null : _addNote,
                    icon: _addingNote
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_outlined, size: 18),
                    label: Text(_addingNote ? 'Posting…' : 'Post note'),
                  ),
                ),
                if (!_canEditTaskFull) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: OutlinedButton.icon(
                      onPressed: _updateStatusAsMember,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Update status'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],

          // ── Activity log ─────────────────────────────────────────────
          Row(
            children: [
              Text('Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${_updates.length} update${_updates.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          if (_updates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No updates yet.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _updates.length,
                itemBuilder: (context, index) {
                  final u = _updates[index];
                  final isMe = currentUserId == u.authorId;
                  final authorLabel = isMe ? 'You' : 'Team member';
                  final dt = u.createdAt != null ? DateTime.tryParse(u.createdAt!)?.toLocal() : null;
                  final dateStr = dt != null
                      ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                      : (u.createdAt ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isMe
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text(
                            isMe ? 'Y' : 'T',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isMe
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(authorLabel,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Text(dateStr,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          )),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(u.note, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // ── Task details (secondary, at bottom) ──────────────────────
          Text('Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.flag_outlined,
            label: 'Status',
            value: statusName,
          ),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Due date',
            value: _formatDueAt(task.dueAt),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Description', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(task.description!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
