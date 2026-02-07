import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
  MaterialsRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<List<MasterMaterial>> listMasterMaterials() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/master-materials');
    final list = res.data ?? [];
    return list.map((e) => MasterMaterial.fromJson(e as Map<String, dynamic>)).toList();
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
    final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials');
    final list = res.data ?? [];
    return list.map((e) => MaterialWithBalance.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LedgerEntry>> listLedger(String projectId, String materialId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials/$materialId/ledger');
    final list = res.data ?? [];
    return list.map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>)).toList();
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
