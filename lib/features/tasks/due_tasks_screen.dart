import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/app_user_state.dart';
import '../dashboard/projects_repository.dart';
import 'task_detail_screen.dart';
import 'tasks_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/sync/sync_status_notifier.dart';

/// A cross-project view of all tasks assigned to the currently logged-in user
/// that are not yet marked done/complete.
class DueTasksScreen extends StatefulWidget {
  const DueTasksScreen({super.key});

  @override
  State<DueTasksScreen> createState() => _DueTasksScreenState();
}

/// Groups tasks by project for display.
class _ProjectTasks {
  final String projectId;
  final String projectName;
  final List<Task> tasks;
  final List<TaskStatus> statuses;

  const _ProjectTasks({
    required this.projectId,
    required this.projectName,
    required this.tasks,
    required this.statuses,
  });
}

class _DueTasksScreenState extends State<DueTasksScreen> {
  final _projectsRepo = ProjectsRepository();
  final _tasksRepo = TasksRepository();

  List<_ProjectTasks> _groups = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  static bool _isDoneStatusName(String? name) {
    if (name == null || name.isEmpty) return false;
    final lower = name.toLowerCase();
    return lower.contains('done') || lower.contains('complete');
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = context.read<AppUserState>().user?.id;
      final projects = await _projectsRepo.getProjects();
      final groups = <_ProjectTasks>[];
      for (final project in projects) {
        try {
          final statuses = await _tasksRepo.listStatuses(project.id);
          final allTasks = await _tasksRepo.listTasks(project.id);
          // Filter: assigned to current user AND not done
          final myTasks = allTasks.where((t) {
            if (userId != null && t.assigneeId != userId) return false;
            final statusName = statuses.where((s) => s.id == t.statusId).firstOrNull?.name;
            return !_isDoneStatusName(statusName);
          }).toList();
          if (myTasks.isNotEmpty) {
            groups.add(_ProjectTasks(
              projectId: project.id,
              projectName: project.name,
              tasks: myTasks,
              statuses: statuses,
            ));
          }
        } catch (_) {
          // Skip projects that fail to load
        }
      }
      if (mounted) setState(() => _groups = groups);
    } catch (e) {
      if (mounted) setState(() => _error = userFacingMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isOverdue(Task t, List<TaskStatus> statuses) {
    final statusName = statuses.where((s) => s.id == t.statusId).firstOrNull?.name;
    if (_isDoneStatusName(statusName)) return false;
    if (t.dueAt == null || t.dueAt!.isEmpty) return false;
    final due = DateTime.tryParse(t.dueAt!);
    if (due == null) return false;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return due.isBefore(today);
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

  Future<void> _updateTaskStatus(
    BuildContext context,
    String projectId,
    Task task,
    List<TaskStatus> statuses,
  ) async {
    String? selectedStatusId = task.statusId;
    final noteController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (statuses.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedStatusId ?? (statuses.isNotEmpty ? statuses.first.id : null),
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setDialogState(() => selectedStatusId = v),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (optional)',
                    hintText: 'Describe what was done…',
                    border: OutlineInputBorder(),
                  ),
                ),
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
    try {
      await TasksRepository().updateTask(projectId, task.id, statusId: selectedStatusId);
      final note = noteController.text.trim();
      if (note.isNotEmpty) {
        await TasksRepository().addTaskUpdate(projectId, task.id, note);
      }
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingMessage(e, context: 'Update task'))),
        );
      }
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
        title: const Text('Due tasks'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _groups.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 48),
                            Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 16),
                            Text(
                              'No due tasks!',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All tasks assigned to you are completed or you have none assigned.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _groups.length,
                          itemBuilder: (context, gi) {
                            final group = _groups[gi];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (gi > 0) const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.construction, size: 16, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          group.projectName,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${group.tasks.length} task${group.tasks.length == 1 ? '' : 's'}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...group.tasks.map((task) {
                                  final overdue = _isOverdue(task, group.statuses);
                                  final statusName = group.statuses
                                          .where((s) => s.id == task.statusId)
                                          .firstOrNull
                                          ?.name ??
                                      '—';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: overdue
                                        ? RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Colors.orange.shade700, width: 2.5),
                                          )
                                        : null,
                                    child: ListTile(
                                      title: Text(task.title),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(statusName,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                        )),
                                              ),
                                              if (task.dueAt != null && task.dueAt!.isNotEmpty)
                                                Text(
                                                  'Due ${_formatDueAt(task.dueAt)}',
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
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (overdue)
                                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_outlined),
                                            tooltip: 'Update status',
                                            onPressed: () => _updateTaskStatus(
                                              context,
                                              group.projectId,
                                              task,
                                              group.statuses,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => TaskDetailScreen(
                                            projectId: group.projectId,
                                            taskId: task.id,
                                            task: task,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                ),
    );
  }
}
