import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

class ProjectSummaryItem {
  const ProjectSummaryItem({
    required this.projectId,
    required this.projectName,
    this.location,
    this.walletBalance = 0,
    this.taskCount = 0,
    this.dueTasks = 0,
    this.todayAttendanceCount = 0,
  });
  final String projectId;
  final String projectName;
  final String? location;
  final double walletBalance;
  final int taskCount;
  final int dueTasks;
  final int todayAttendanceCount;

  static ProjectSummaryItem fromJson(Map<String, dynamic> json) {
    return ProjectSummaryItem(
      projectId: json['project_id'] as String,
      projectName: json['project_name'] as String,
      location: json['location'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      taskCount: (json['task_count'] as int?) ?? 0,
      dueTasks: (json['due_tasks'] as int?) ?? 0,
      todayAttendanceCount: (json['today_attendance_count'] as int?) ?? 0,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.projects,
    this.totalSites = 0,
    this.totalTodayPresent = 0,
    this.totalWalletBalance = 0,
    this.totalTasks = 0,
    this.totalDueTasks = 0,
  });
  final List<ProjectSummaryItem> projects;
  final int totalSites;
  final int totalTodayPresent;
  final double totalWalletBalance;
  final int totalTasks;
  final int totalDueTasks;

  static DashboardSummary fromJson(Map<String, dynamic> json) {
    final projectsList = json['projects'] as List<dynamic>? ?? [];
    final projects = projectsList.map((e) => ProjectSummaryItem.fromJson(e as Map<String, dynamic>)).toList();
    final totalWallet = projects.fold<double>(0, (s, p) => s + p.walletBalance);
    final totalDue = projects.fold<int>(0, (s, p) => s + p.dueTasks);
    final totalTasks = projects.fold<int>(0, (s, p) => s + p.taskCount);
    final totalPresent = projects.fold<int>(0, (s, p) => s + p.todayAttendanceCount);
    return DashboardSummary(
      projects: projects,
      totalSites: projects.length,
      totalTodayPresent: totalPresent,
      totalWalletBalance: totalWallet,
      totalTasks: totalTasks,
      totalDueTasks: totalDue,
    );
  }
}

class DashboardRepository {
  DashboardRepository({AppDatabase? db}) : _dio = ApiClient.instance.dio, _db = db ?? AppDatabase();
  final Dio _dio;
  final AppDatabase _db;

  static const _doneStatusNames = {'Done', 'Complete'};

  Future<DashboardSummary?> getSummary({String? userId}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/dashboard/summary');
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      return DashboardSummary.fromJson(data);
    } on DioException catch (e) {
      final isNetwork = e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown;
      if (isNetwork) {
        try {
          return await getSummaryFromCache(userId: userId);
        } on Object {
          return const DashboardSummary(projects: []);
        }
      }
      rethrow;
    }
  }

  /// Builds dashboard summary from local cache. When [userId] is set, only counts tasks assigned to that user (matches API for non-admin).
  Future<DashboardSummary> getSummaryFromCache({String? userId}) async {
    try {
      final projectRows = await _db.select(_db.cacheProjects).get();
      final today = _todayIso();
      final items = <ProjectSummaryItem>[];
      int totalPresent = 0;
      double totalWallet = 0;
      int totalTasks = 0;
      int totalDue = 0;
      final onlyMyTasks = userId != null && userId.isNotEmpty;

      for (final row in projectRows) {
        final map = jsonDecode(row.payloadJson) as Map<String, dynamic>?;
        if (map == null) continue;
        final projectId = map['id'] as String?;
        final projectName = map['name'] as String? ?? '';
        final location = map['location'] as String? ?? map['address'] as String?;
        if (projectId == null) continue;

        final balanceRow = await (_db.select(_db.cacheWalletBalance)..where((t) => t.projectId.equals(projectId))).getSingleOrNull();
        final walletBalance = balanceRow?.balance ?? 0.0;

        final taskRows = await (_db.select(_db.cacheTasks)..where((t) => t.projectId.equals(projectId))).get();
        final statusRows = await (_db.select(_db.cacheTaskStatuses)..where((t) => t.projectId.equals(projectId))).get();
        final statusIdToName = <String, String>{};
        for (final sr in statusRows) {
          final sm = jsonDecode(sr.payloadJson) as Map<String, dynamic>?;
          if (sm != null && sm['id'] != null) statusIdToName[sm['id'] as String] = (sm['name'] as String?) ?? '';
        }
        int dueCount = 0;
        int taskCount = 0;
        for (final tr in taskRows) {
          final tm = jsonDecode(tr.payloadJson) as Map<String, dynamic>?;
          if (tm == null) continue;
          if (onlyMyTasks && tm['assignee_id'] != userId) continue;
          taskCount++;
          final dueAt = tm['due_at'] as String?;
          if (dueAt == null || dueAt.isEmpty) continue;
          final dueDate = dueAt.length >= 10 ? dueAt.substring(0, 10) : null;
          if (dueDate == null || dueDate.compareTo(today) > 0) continue;
          final statusName = (statusIdToName[tm['status_id'] as String?] ?? '').trim();
          if (_doneStatusNames.any((n) => n.toLowerCase() == statusName.toLowerCase())) continue;
          dueCount++;
        }

        final attendanceRows = await (_db.select(_db.cacheAttendance)..where((t) => t.projectId.equals(projectId))).get();
        int todayPresent = 0;
        for (final ar in attendanceRows) {
          final am = jsonDecode(ar.payloadJson) as Map<String, dynamic>?;
          if (am != null && am['date'] == today) todayPresent++;
        }

        items.add(ProjectSummaryItem(
          projectId: projectId,
          projectName: projectName,
          location: location,
          walletBalance: walletBalance,
          taskCount: taskCount,
          dueTasks: dueCount,
          todayAttendanceCount: todayPresent,
        ));
        totalPresent += todayPresent;
        totalWallet += walletBalance;
        totalTasks += taskCount;
        totalDue += dueCount;
      }

      return DashboardSummary(
        projects: items,
        totalSites: items.length,
        totalTodayPresent: totalPresent,
        totalWalletBalance: totalWallet,
        totalTasks: totalTasks,
        totalDueTasks: totalDue,
      );
    } on Object {
      return const DashboardSummary(projects: []);
    }
  }

  static String _todayIso() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
