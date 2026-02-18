import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

/// Fixed units; must match backend MATERIAL_UNITS.
const List<String> materialUnits = [
  'kg', 'L', 'pieces', 'm', 'm²', 'bags', 'tonnes', 'cubic m', 'boxes', 'rolls',
];

class MasterMaterial {
  const MasterMaterial({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.unit,
    this.createdAt,
  });
  final String id;
  final String tenantId;
  final String name;
  final String unit;
  final String? createdAt;

  static MasterMaterial fromJson(Map<String, dynamic> json) {
    return MasterMaterial(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      createdAt: json['created_at'] as String?,
    );
  }
}

class MaterialWithBalance {
  const MaterialWithBalance({
    required this.id,
    required this.projectId,
    required this.name,
    required this.unit,
    required this.balance,
    this.createdAt,
  });
  final String id;
  final String projectId;
  final String name;
  final String unit;
  final double balance;
  final String? createdAt;

  static MaterialWithBalance fromJson(Map<String, dynamic> json) {
    return MaterialWithBalance(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
    );
  }
}

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.materialId,
    required this.type,
    required this.quantity,
    this.notes,
    this.receiptPath,
    this.createdAt,
    this.createdBy,
  });
  final String id;
  final String materialId;
  final String type;
  final double quantity;
  final String? notes;
  final String? receiptPath;
  final String? createdAt;
  final String? createdBy;

  static LedgerEntry fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      materialId: json['material_id'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      notes: json['notes'] as String?,
      receiptPath: json['receipt_path'] as String?,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }
}

class MaterialsRepository {
  MaterialsRepository({AppDatabase? db}) : _db = db ?? AppDatabase(), _dio = ApiClient.instance.dio;
  final AppDatabase _db;
  final Dio _dio;

  Future<List<MasterMaterial>> listMasterMaterials() async {
    final rows = await _db.select(_db.cacheMasterMaterials).get();
    return rows.map((r) => MasterMaterial.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<MaterialWithBalance> createMaterial(
    String projectId, {
    String? masterMaterialId,
    String? name,
    String? unit,
  }) async {
    final Map<String, dynamic> data = {};
    if (masterMaterialId != null && masterMaterialId.isNotEmpty) {
      data['master_material_id'] = masterMaterialId;
    } else if (name != null && unit != null) {
      data['name'] = name;
      data['unit'] = unit;
    } else {
      throw ArgumentError('Provide masterMaterialId or both name and unit');
    }
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/materials/$projectId/materials',
      data: data,
    );
    return MaterialWithBalance.fromJson(res.data!);
  }

  Future<List<MaterialWithBalance>> listMaterials(String projectId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials');
      final list = res.data ?? [];
      final materials = <MaterialWithBalance>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheMaterials).insert(
          CacheMaterialsCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheMaterialsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        materials.add(MaterialWithBalance.fromJson(item));
      }
      return materials;
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheMaterials)..where((t) => t.projectId.equals(projectId))).get();
    return rows.map((r) => MaterialWithBalance.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<List<LedgerEntry>> listLedger(String projectId, String materialId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials/$materialId/ledger');
      final list = res.data ?? [];
      final entries = <LedgerEntry>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheMaterialLedger).insert(
          CacheMaterialLedgerCompanion.insert(id: id, projectId: projectId, materialId: materialId, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheMaterialLedgerCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        entries.add(LedgerEntry.fromJson(item));
      }
      return entries;
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheMaterialLedger)
          ..where((t) => Expression.and([t.projectId.equals(projectId), t.materialId.equals(materialId)])))
        .get();
    return rows.map((r) => LedgerEntry.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<LedgerEntry> addLedgerEntry(
    String projectId,
    String materialId, {
    required String type,
    required double quantity,
    String? notes,
    String? receiptFilePath,
  }) async {
    final map = <String, dynamic>{
      'type': type,
      'quantity': quantity,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    if (receiptFilePath != null && receiptFilePath.isNotEmpty && type == 'in') {
      map['receipt'] = await MultipartFile.fromFile(
        receiptFilePath,
        filename: receiptFilePath.split(RegExp(r'[/\\]')).last,
      );
    }
    final formData = FormData.fromMap(map);
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/materials/$projectId/materials/$materialId/ledger',
      data: formData,
    );
    return LedgerEntry.fromJson(res.data!);
  }
}
