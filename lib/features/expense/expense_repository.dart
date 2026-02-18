import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.projectId,
    required this.type,
    required this.amount,
    this.receiptStoragePath,
    this.notes,
    this.createdAt,
    this.createdBy,
  });
  final String id;
  final String projectId;
  final String type;
  final double amount;
  final String? receiptStoragePath;
  final String? notes;
  final String? createdAt;
  final String? createdBy;

  static ExpenseTransaction fromJson(Map<String, dynamic> json) {
    return ExpenseTransaction(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      receiptStoragePath: json['receipt_storage_path'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }
}

class WalletData {
  const WalletData({required this.balance, required this.transactions});
  final double balance;
  final List<ExpenseTransaction> transactions;

  static WalletData fromJson(Map<String, dynamic> json) {
    final list = json['transactions'] as List<dynamic>? ?? [];
    return WalletData(
      balance: (json['balance'] as num).toDouble(),
      transactions: list.map((e) => ExpenseTransaction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ExpenseRepository {
  ExpenseRepository({AppDatabase? db}) : _db = db ?? AppDatabase(), _dio = ApiClient.instance.dio;
  final AppDatabase _db;
  final Dio _dio;

  Future<WalletData> getWallet(String projectId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/expense/$projectId');
      final data = res.data;
      if (data != null) {
        final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final updatedAt = data['updated_at'] as String? ?? DateTime.now().toUtc().toIso8601String();
        await _db.into(_db.cacheWalletBalance).insert(
          CacheWalletBalanceCompanion.insert(projectId: projectId, balance: balance, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheWalletBalanceCompanion(balance: Value(balance), updatedAt: Value(updatedAt))),
        );
        final list = data['transactions'] as List<dynamic>? ?? [];
        for (final e in list) {
          final item = e as Map<String, dynamic>;
          final id = item['id'] as String?;
          if (id == null) continue;
          final updatedAtTx = item['updated_at'] as String? ?? item['created_at'] as String?;
          final json = jsonEncode(item);
          await _db.into(_db.cacheExpenseTransactions).insert(
            CacheExpenseTransactionsCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAtTx)),
            onConflict: DoUpdate((old) => CacheExpenseTransactionsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAtTx))),
          );
        }
        final transactions = list.map((e) => ExpenseTransaction.fromJson(e as Map<String, dynamic>)).toList();
        return WalletData(balance: balance, transactions: transactions);
      }
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final balanceRow = await (_db.select(_db.cacheWalletBalance)..where((t) => t.projectId.equals(projectId))).getSingleOrNull();
    final balance = balanceRow?.balance ?? 0.0;
    final txRows = await (_db.select(_db.cacheExpenseTransactions)..where((t) => t.projectId.equals(projectId))..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    final transactions = txRows.map((r) => ExpenseTransaction.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
    return WalletData(balance: balance, transactions: transactions);
  }

  Future<ExpenseTransaction> addCredit(String projectId, double amount, {String? notes}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/expense/$projectId/credit',
      data: <String, dynamic>{
        'amount': amount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return ExpenseTransaction.fromJson(res.data!);
  }

  Future<ExpenseTransaction> addDebit(
    String projectId,
    double amount,
    String receiptPath, {
    String? notes,
  }) async {
    final file = File(receiptPath);
    final formData = FormData.fromMap({
      'amount': amount,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'receipt': await MultipartFile.fromFile(
        receiptPath,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/expense/$projectId/debit',
      data: formData,
    );
    return ExpenseTransaction.fromJson(res.data!);
  }
}
