import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/app_user_state.dart';
import 'projects_repository.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/sync/sync_status_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Project>? _projects;
  bool _projectsLoading = true;
  String? _projectsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppUserState>().load();
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    setState(() {
      _projectsLoading = true;
      _projectsError = null;
    });
    try {
      final list = await ProjectsRepository().getProjects();
      if (mounted) setState(() => _projects = list);
    } catch (e) {
      if (mounted) setState(() => _projectsError = e.toString());
    } finally {
      if (mounted) setState(() => _projectsLoading = false);
    }
  }

  Future<void> _logout() async {
    await SecureTokenStorage().delete();
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.read<AppUserState>().clear();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldOps'),
        actions: [
          Consumer<SyncStatusNotifier>(
            builder: (context, sync, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 14, bottom: 14),
                child: Center(
                  child: Text(
                    sync.isSynced ? 'Synced' : '${sync.pendingCount} pending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: sync.isSynced
                              ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9)
                              : null,
                        ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<AppUserState>(
          builder: (context, state, _) {
            final name = state.user?.fullName ?? state.user?.email ?? 'User';
            final tenantName = state.tenant?.name?.trim().isNotEmpty == true
                ? state.tenant!.name
                : null;
            return ListView(
              padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                if (tenantName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      tenantName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<AppUserState>(
        builder: (context, state, _) {
          if (!state.loaded && state.error == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => state.load(), child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          if (_projectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_projectsError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_projectsError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _loadProjects, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final projects = _projects ?? [];
          return RefreshIndicator(
            onRefresh: _loadProjects,
            child: projects.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No projects',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Projects you are assigned to will appear here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Projects',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        );
                      }
                      final project = projects[index - 1];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            project.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: project.displayLocation != null
                              ? Text(
                                  project.displayLocation!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/project/${project.id}', extra: project),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
