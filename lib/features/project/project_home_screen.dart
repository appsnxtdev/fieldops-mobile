import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/projects_repository.dart';
import '../../core/theme/app_colors.dart';

class ProjectHomeScreen extends StatefulWidget {
  const ProjectHomeScreen({super.key, required this.projectId, this.project});

  final String projectId;
  final Project? project;

  @override
  State<ProjectHomeScreen> createState() => _ProjectHomeScreenState();
}

class _ProjectHomeScreenState extends State<ProjectHomeScreen> {
  Project? _project;
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
    final name = _project?.name ?? 'Site';
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
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            _NavTile(
              icon: Icons.fingerprint,
              label: 'Mark attendance',
              subtitle: 'Check in / Check out',
              onTap: () => context.go('/project/${widget.projectId}/attendance'),
            ),
            _NavTile(
              icon: Icons.assignment,
              label: 'Daily report',
              subtitle: 'Add note or photo for the day',
              onTap: () => context.go('/project/${widget.projectId}/daily-report'),
            ),
            _NavTile(
              icon: Icons.task_alt,
              label: 'Tasks',
              subtitle: 'View and update your tasks',
              onTap: () => context.go('/project/${widget.projectId}/tasks'),
            ),
            _NavTile(
              icon: Icons.inventory_2,
              label: 'Materials',
              subtitle: 'Record material in or out',
              onTap: () => context.go('/project/${widget.projectId}/materials'),
            ),
            _NavTile(
              icon: Icons.account_balance_wallet,
              label: 'Site wallet',
              subtitle: 'View balance · Add money',
              onTap: () => context.go('/project/${widget.projectId}/wallet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
