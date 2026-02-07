import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
  ExpenseRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<WalletData> getWallet(String projectId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/expense/$projectId');
    return WalletData.fromJson(res.data!);
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
