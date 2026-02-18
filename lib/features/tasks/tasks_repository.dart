import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

class TaskStatus {
  const TaskStatus({
    required this.id,
    required this.projectId,
    required this.name,
    this.sortOrder = 0,
    this.createdAt,
  });
  final String id;
  final String projectId;
  final String name;
  final int sortOrder;
  final String? createdAt;

  static TaskStatus fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.statusId,
    this.assigneeId,
    this.assigneeName,
    this.createdBy,
    this.dueAt,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String? statusId;
  final String? assigneeId;
  final String? assigneeName;
  final String? createdBy;
  final String? dueAt;
  final String? createdAt;
  final String? updatedAt;

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      statusId: json['status_id'] as String?,
      assigneeId: json['assignee_id'] as String?,
      assigneeName: json['assignee_name'] as String?,
      createdBy: json['created_by'] as String?,
      dueAt: json['due_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class TaskUpdateNote {
  const TaskUpdateNote({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.authorId,
    required this.note,
    this.createdAt,
  });
  final String id;
  final String taskId;
  final String projectId;
  final String authorId;
  final String note;
  final String? createdAt;

  static TaskUpdateNote fromJson(Map<String, dynamic> json) {
    return TaskUpdateNote(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      projectId: json['project_id'] as String,
      authorId: json['author_id'] as String,
      note: json['note'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class TasksRepository {
  TasksRepository({AppDatabase? db}) : _db = db ?? AppDatabase(), _dio = ApiClient.instance.dio;
  final AppDatabase _db;
  final Dio _dio;

  Future<List<TaskStatus>> listStatuses(String projectId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/statuses');
      final list = res.data ?? [];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheTaskStatuses).insert(
          CacheTaskStatusesCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheTaskStatusesCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
      }
      return list.map((e) => TaskStatus.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheTaskStatuses)..where((t) => t.projectId.equals(projectId))).get();
    return rows.map((r) => TaskStatus.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<List<Task>> listTasks(String projectId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks');
      final list = res.data ?? [];
      final tasks = <Task>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheTasks).insert(
          CacheTasksCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheTasksCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        tasks.add(Task.fromJson(item));
      }
      return tasks;
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheTasks)..where((t) => t.projectId.equals(projectId))).get();
    return rows.map((r) => Task.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<Task?> getTask(String projectId, String taskId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/tasks/$projectId/tasks/$taskId');
      final item = res.data;
      if (item != null) {
        final id = item['id'] as String?;
        if (id != null) {
          final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
          final json = jsonEncode(item);
          await _db.into(_db.cacheTasks).insert(
            CacheTasksCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
            onConflict: DoUpdate((old) => CacheTasksCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
          );
          return Task.fromJson(item);
        }
      }
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final row = await (_db.select(_db.cacheTasks)..where((t) => Expression.and([t.projectId.equals(projectId), t.id.equals(taskId)]))).getSingleOrNull();
    if (row == null) return null;
    return Task.fromJson(jsonDecode(row.payloadJson) as Map<String, dynamic>);
  }

  Future<Task> createTask(
    String projectId, {
    required String title,
    String? description,
    String? statusId,
    String? assigneeId,
    String? dueAt,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks/$projectId/tasks',
      data: <String, dynamic>{
        'title': title,
        if (description != null) 'description': description,
        if (statusId != null) 'status_id': statusId,
        if (assigneeId != null) 'assignee_id': assigneeId,
        if (dueAt != null) 'due_at': dueAt,
      },
    );
    return Task.fromJson(res.data!);
  }

  Future<Task> updateTask(
    String projectId,
    String taskId, {
    String? title,
    String? description,
    String? statusId,
    String? assigneeId,
    String? dueAt,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (statusId != null) data['status_id'] = statusId;
    if (assigneeId != null) data['assignee_id'] = assigneeId;
    if (dueAt != null) data['due_at'] = dueAt;
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/tasks/$projectId/tasks/$taskId',
      data: data,
    );
    return Task.fromJson(res.data!);
  }

  Future<List<TaskUpdateNote>> listTaskUpdates(String projectId, String taskId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks/$taskId/updates');
      final list = res.data ?? [];
      final updates = <TaskUpdateNote>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheTaskUpdates).insert(
          CacheTaskUpdatesCompanion.insert(id: id, taskId: taskId, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheTaskUpdatesCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        updates.add(TaskUpdateNote.fromJson(item));
      }
      return updates;
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheTaskUpdates)
          ..where((t) => Expression.and([t.projectId.equals(projectId), t.taskId.equals(taskId)])))
        .get();
    return rows.map((r) => TaskUpdateNote.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<TaskUpdateNote> addTaskUpdate(String projectId, String taskId, String note) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks/$projectId/tasks/$taskId/updates',
      data: <String, dynamic>{'note': note},
    );
    return TaskUpdateNote.fromJson(res.data!);
  }
}
