import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../dashboard/projects_repository.dart';
import 'tasks_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/theme/app_colors.dart';
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

  /// Assignee filter — only visible for admins. null = show all.
  String? _filterAssigneeId;

  bool get _canCreateTask => _projectRole == 'admin';

  static bool _isDoneStatusName(String? name) {
    if (name == null || name.isEmpty) return false;
    final lower = name.toLowerCase();
    return lower.contains('done') || lower.contains('complete');
  }

  /// Unique (assigneeId, assigneeName) pairs from loaded tasks, for admin filter.
  List<({String id, String name})> get _assigneeOptions {
    final seen = <String>{};
    final result = <({String id, String name})>[];
    for (final t in _tasks) {
      if (t.assigneeId != null && t.assigneeId!.isNotEmpty && seen.add(t.assigneeId!)) {
        result.add((id: t.assigneeId!, name: t.assigneeName ?? t.assigneeId!));
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  List<Task> get _filteredAndSortedTasks {
    List<Task> list = _tasks;
    // Admin assignee filter
    if (_filterAssigneeId != null) {
      list = list.where((t) => t.assigneeId == _filterAssigneeId).toList();
    }
    list = List<Task>.from(list);
    list.sort((a, b) {
      final aDue = a.dueAt != null && a.dueAt!.isNotEmpty ? DateTime.tryParse(a.dueAt!) : null;
      final bDue = b.dueAt != null && b.dueAt!.isNotEmpty ? DateTime.tryParse(b.dueAt!) : null;
      if (aDue != null && bDue != null) return bDue.compareTo(aDue);
      if (aDue != null) return -1;
      if (bDue != null) return 1;
      final aC = DateTime.tryParse(a.createdAt ?? '');
      final bC = DateTime.tryParse(b.createdAt ?? '');
      if (aC != null && bC != null) return bC.compareTo(aC);
      if (aC != null) return -1;
      if (bC != null) return 1;
      return 0;
    });
    return list;
  }

  bool _isOverdue(Task t) {
    final statusName = _statusName(t.statusId);
    if (_isDoneStatusName(statusName)) return false;
    if (t.dueAt == null || t.dueAt!.isEmpty) return false;
    final due = DateTime.tryParse(t.dueAt!);
    if (due == null) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return due.isBefore(today);
  }

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

  static Color _statusColor(BuildContext context, String? statusName) {
    if (statusName == null || statusName.isEmpty) return Theme.of(context).colorScheme.onSurfaceVariant;
    final lower = statusName.toLowerCase();
    if (lower.contains('done') || lower.contains('complete')) return AppColors.success;
    if (lower.contains('progress')) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.onSurfaceVariant;
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
        _showToast(userFacingMessage(e, context: 'Add task'));
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Add task'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignees = _assigneeOptions;
    final isAdmin = _projectRole == 'admin';
    final filtered = _filteredAndSortedTasks;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/project/${widget.projectId}')),
        title: const Text('My tasks'),
      ),
      body: _loading && _tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Assignee filter — admins only
                  if (isAdmin && assignees.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _filterAssigneeId == null,
                            onSelected: (_) => setState(() => _filterAssigneeId = null),
                          ),
                          const SizedBox(width: 8),
                          ...assignees.map((a) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(a.name),
                                  selected: _filterAssigneeId == a.id,
                                  onSelected: (_) => setState(() => _filterAssigneeId = a.id),
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          _canCreateTask ? 'No tasks yet. Tap + to add one.' : 'No tasks yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...filtered.map((t) {
                      final statusName = _statusName(t.statusId);
                      final statusColor = _statusColor(context, statusName);
                      final overdue = _isOverdue(t);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: overdue
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.orange.shade700, width: 2.5),
                              )
                            : null,
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(statusName, style: TextStyle(fontSize: 12, color: statusColor)),
                                    backgroundColor: statusColor.withValues(alpha: 0.15),
                                    side: BorderSide(color: statusColor.withValues(alpha: 0.5)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  if (t.dueAt != null && t.dueAt!.isNotEmpty)
                                    Text(
                                      'Due ${_formatDueAt(t.dueAt)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: overdue
                                                ? Colors.orange.shade700
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: overdue
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right),
                                  ],
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () => context.push('/project/${widget.projectId}/tasks/${t.id}', extra: t),
                        ),
                      );
                    }),
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
