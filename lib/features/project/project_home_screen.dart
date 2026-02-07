import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/projects_repository.dart';

class ProjectHomeScreen extends StatefulWidget {
  const ProjectHomeScreen({super.key, required this.projectId, this.project});

  final String projectId;
  final Project? project;

  @override
  State<ProjectHomeScreen> createState() => _ProjectHomeScreenState();
}

class _ProjectHomeScreenState extends State<ProjectHomeScreen> {
  Project? _project;
  String? _projectRole;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _project = widget.project;
      _loading = false;
    } else {
      _fetchProject();
    }
    _fetchMyRole();
  }

  Future<void> _fetchProject() async {
    final p = await ProjectsRepository().getProject(widget.projectId);
    if (mounted) {
      setState(() {
        _project = p;
        _loading = false;
      });
    }
  }

  Future<void> _fetchMyRole() async {
    final role = await ProjectsRepository().getMyProjectAccess(widget.projectId);
    if (mounted) setState(() => _projectRole = role);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          title: const Text('Project'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final name = _project?.name ?? 'Project';
    final roleLabel = _projectRole != null ? _projectRole!.toUpperCase() : '—';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: const Text('Your role'),
                subtitle: Text(roleLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                )),
              ),
            ),
            Expanded(
              child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _NavTile(
              icon: Icons.fingerprint,
              label: 'Attendance',
              onTap: () => context.go('/project/${widget.projectId}/attendance'),
            ),
            _NavTile(
              icon: Icons.account_balance_wallet,
              label: 'Wallet',
              onTap: () => context.go('/project/${widget.projectId}/wallet'),
            ),
            _NavTile(
              icon: Icons.assignment,
              label: 'Daily Report',
              onTap: () => context.go('/project/${widget.projectId}/daily-report'),
            ),
            _NavTile(
              icon: Icons.task_alt,
              label: 'Tasks',
              onTap: () => context.go('/project/${widget.projectId}/tasks'),
            ),
            _NavTile(
              icon: Icons.inventory_2,
              label: 'Materials',
              onTap: () => context.go('/project/${widget.projectId}/materials'),
            ),
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
