import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../network/api_client.dart';
import '../storage/secure_token_storage.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/projects_repository.dart';
import '../../features/project/project_home_screen.dart';
import '../../features/attendance/attendance_screen.dart';
import '../../features/daily_report/daily_report_screen.dart';
import '../../features/expense/wallet_screen.dart';
import '../../features/materials/material_ledger_screen.dart';
import '../../features/materials/materials_repository.dart';
import '../../features/materials/materials_screen.dart';
import '../../features/project/project_placeholder_screen.dart';
import '../../features/tasks/task_detail_screen.dart';
import '../../features/tasks/tasks_repository.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/sync/pending_sync_screen.dart';

GoRouter createAppRouter() {
  final router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await SecureTokenStorage().read();
      final isLogin = state.matchedLocation == '/login';
      if (token == null || token.isEmpty) {
        return isLogin ? null : '/login';
      }
      return isLogin ? '/dashboard' : null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/pending-sync',
        builder: (context, state) => const PendingSyncScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final project = state.extra as Project?;
          return ProjectHomeScreen(projectId: id, project: project);
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'attendance',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AttendanceScreen(projectId: id);
            },
          ),
          GoRoute(
            path: 'wallet',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return WalletScreen(projectId: id);
            },
          ),
          GoRoute(
            path: 'daily-report',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DailyReportScreen(projectId: id);
            },
          ),
          GoRoute(
            path: 'tasks',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TasksScreen(projectId: id);
            },
            routes: <RouteBase>[
              GoRoute(
                path: ':taskId',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final taskId = state.pathParameters['taskId']!;
                  final task = state.extra as Task?;
                  return TaskDetailScreen(projectId: id, taskId: taskId, task: task);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'materials',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaterialsScreen(projectId: id);
            },
            routes: <RouteBase>[
              GoRoute(
                path: ':materialId',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final materialId = state.pathParameters['materialId']!;
                  final material = state.extra as MaterialWithBalance?;
                  return MaterialLedgerScreen(projectId: id, materialId: materialId, material: material);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ApiClient.setUnauthorizedCallback(() => router.go('/login'));
  return router;
}

GoRoute _projectFeatureRoute(String path, String title) {
  return GoRoute(
    path: path,
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return ProjectPlaceholderScreen(projectId: id, title: title);
    },
  );
}
