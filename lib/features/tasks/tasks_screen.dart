import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../dashboard/projects_repository.dart';
import 'tasks_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

/// Special filter value: show only "To Do" and "In Progress" (exclude Done).
const String _kFilterActive = 'active';
/// Special filter value: show all statuses.
const String _kFilterAll = 'all';

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TasksRepository();
  final _projectsRepo = ProjectsRepository();
  final _syncRepo = SyncQueueRepository();

  List<TaskStatus> _statuses = [];
  List<Task> _tasks = [];
  String? _projectRole; // admin | member | viewer
  bool _loading = true;
  /// Status filter: null or _kFilterActive = active only, _kFilterAll = all, else status id.
  String? _filterStatusId = _kFilterActive;

  bool get _canCreateTask => _projectRole == 'admin' || _projectRole == 'member';

  static bool _isDoneStatusName(String? name) {
    if (name == null || name.isEmpty) return false;
    final lower = name.toLowerCase();
    return lower.contains('done') || lower.contains('complete');
  }

  Set<String> get _activeStatusIds => {
        ..._statuses.where((s) => !_isDoneStatusName(s.name)).map((s) => s.id),
      };

  List<Task> get _filteredAndSortedTasks {
    List<Task> list = _tasks;
    if (_filterStatusId == _kFilterActive) {
      final activeIds = _activeStatusIds;
      list = list.where((t) => t.statusId != null && activeIds.contains(t.statusId)).toList();
    } else if (_filterStatusId != null && _filterStatusId != _kFilterAll) {
      list = list.where((t) => t.statusId == _filterStatusId).toList();
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
    if (lower.contains('done') || lower.contains('complete')) return const Color(0xFF2D8A6E);
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
                  if (_statuses.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        FilterChip(
                          label: const Text('Active'),
                          selected: _filterStatusId == _kFilterActive,
                          onSelected: (_) => setState(() => _filterStatusId = _kFilterActive),
                        ),
                        ..._statuses.map((s) {
                          final selected = _filterStatusId == s.id;
                          return FilterChip(
                            label: Text(s.name),
                            selected: selected,
                            onSelected: (_) => setState(() => _filterStatusId = s.id),
                          );
                        }),
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterStatusId == _kFilterAll,
                          onSelected: (_) => setState(() => _filterStatusId = _kFilterAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_filteredAndSortedTasks.isEmpty)
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
                    ..._filteredAndSortedTasks.map((t) {
                      final statusName = _statusName(t.statusId);
                      final statusColor = _statusColor(context, statusName);
                      final overdue = _isOverdue(t);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
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
                                  if (overdue)
                                    Chip(
                                      label: Text('Overdue', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
                                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  Text(
                                    t.assigneeName != null && t.assigneeName!.isNotEmpty
                                        ? 'Assigned to ${t.assigneeName!}'
                                        : 'Unassigned',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  if (t.dueAt != null && t.dueAt!.isNotEmpty)
                                    Text(
                                      overdue ? 'Due ${_formatDueAt(t.dueAt)} (overdue)' : 'Due ${_formatDueAt(t.dueAt)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: overdue ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
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
