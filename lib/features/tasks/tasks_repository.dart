import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
  TasksRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<List<TaskStatus>> listStatuses(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/statuses');
    final list = res.data ?? [];
    return list.map((e) => TaskStatus.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Task>> listTasks(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks');
    final list = res.data ?? [];
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task?> getTask(String projectId, String taskId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/tasks/$projectId/tasks/$taskId');
      return Task.fromJson(res.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
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
    final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks/$taskId/updates');
    final list = res.data ?? [];
    return list.map((e) => TaskUpdateNote.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskUpdateNote> addTaskUpdate(String projectId, String taskId, String note) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks/$projectId/tasks/$taskId/updates',
      data: <String, dynamic>{'note': note},
    );
    return TaskUpdateNote.fromJson(res.data!);
  }
}
