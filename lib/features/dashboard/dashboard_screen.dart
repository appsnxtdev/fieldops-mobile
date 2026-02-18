import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/app_user_state.dart';
import 'dashboard_repository.dart';
import 'projects_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/sync/sync_status_notifier.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Project>? _projects;
  DashboardSummary? _summary;
  bool _projectsLoading = true;
  String? _projectsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppUserState>();
      if (!state.loaded) state.load();
      _loadData();
      _maybeShowOfflineTip();
    });
  }

  Future<void> _maybeShowOfflineTip() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('offline_tip_seen') == true) return;
    await prefs.setBool('offline_tip_seen', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'You can use the app offline; data will sync when you\'re back online.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _projectsLoading = true;
      _projectsError = null;
      _summary = null;
    });
    try {
      final userId = context.read<AppUserState>().user?.id;
      final summary = await DashboardRepository().getSummary(userId: userId);
      final list = await ProjectsRepository().getProjects();
      if (mounted) {
        setState(() {
          _summary = summary;
          _projects = list;
        });
        context.read<SyncStatusNotifier>().refresh();
      }
    } catch (e) {
      if (mounted) setState(() => _projectsError = userFacingMessage(e));
    } finally {
      if (mounted) setState(() => _projectsLoading = false);
    }
  }

  static String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _logout() async {
    final storage = SecureTokenStorage();
    await storage.delete();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    if (!mounted) return;
    context.read<AppUserState>().clear();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My sites'),
        actions: [
          Consumer<SyncStatusNotifier>(
            builder: (context, sync, _) {
              final statusText = _projectsLoading
                  ? 'Syncing'
                  : (sync.isSynced ? 'Synced' : '${sync.pendingCount} pending');
              return Padding(
                padding: const EdgeInsets.only(right: 4, top: 14, bottom: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_projectsLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<SyncStatusNotifier>(
            builder: (context, sync, _) {
              return Tooltip(
                message: sync.isOnline ? 'Connected' : 'Disconnected',
                child: Icon(
                  sync.isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 22,
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
        child: ListView(
          padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
          children: [
            Consumer<AppUserState>(
              builder: (context, state, _) {
                final name = state.user?.fullName ?? state.user?.email ?? 'User';
                final tenantName = state.tenant?.name?.trim().isNotEmpty == true
                    ? state.tenant!.name
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              subtitle: Consumer<AppUserState>(
                builder: (context, state, _) {
                  final email = state.user?.email;
                  if (email == null || email.isEmpty) return const SizedBox.shrink();
                  return Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            Consumer<SyncStatusNotifier>(
              builder: (context, sync, _) {
                return ListTile(
                  leading: Icon(
                    sync.isOnline ? Icons.wifi : Icons.wifi_off,
                  ),
                  title: Text(sync.isSynced ? 'Synced' : '${sync.pendingCount} pending'),
                  subtitle: Text(
                    sync.isOnline
                        ? (sync.isSynced ? 'All data is up to date' : 'Will sync when possible')
                        : 'Changes will sync when back online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/pending-sync');
                  },
                );
              },
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
                    FilledButton(onPressed: _loadData, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final projects = _projects ?? [];
          final summary = _summary;
          final dateStr = _formatDate(DateTime.now());
          return RefreshIndicator(
            onRefresh: _loadData,
            child: projects.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'My sites',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No sites yet',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sites you\'re assigned to will appear here. Ask your admin to add you to a site.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (_projectsError == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'When you\'re back online, pull to refresh to load your sites.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryChip(
                                icon: Icons.account_balance_wallet,
                                label: 'Wallet',
                                value: '₹${summary.totalWalletBalance.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryChip(
                                icon: Icons.assignment_late,
                                label: 'Due tasks',
                                value: '${summary.totalDueTasks}',
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'My sites',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      ...projects.map((project) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => context.go('/project/${project.id}', extra: project),
                            borderRadius: BorderRadius.circular(AppColors.radiusLg),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(Icons.construction, size: 32, color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap to mark attendance, add report, update tasks.',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
