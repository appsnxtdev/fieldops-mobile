import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'expense_repository.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _repo = ExpenseRepository();
  final _syncRepo = SyncQueueRepository();
  WalletData? _wallet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getWallet(widget.projectId);
      if (mounted) {
        setState(() => _wallet = data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
  }

  Future<void> _addMoney() async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (submitted != true) return;
    final amount = double.tryParse(amountController.text.trim());
    final notes = notesController.text.trim();
    if (amount == null || amount <= 0) return;
    try {
      await _repo.addCredit(widget.projectId, amount, notes: notes.isEmpty ? null : notes);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('expense_credit', {
          'project_id': widget.projectId,
          'amount': amount,
          'notes': notes.isEmpty ? null : notes,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved offline. Will sync when online.')));
          _load();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
        }
      }
    }
  }

  Future<void> _spendMoney() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    final receiptPath = file.path;
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Spend money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (submitted != true) return;
    final amount = double.tryParse(amountController.text.trim());
    final notes = notesController.text.trim();
    if (amount == null || amount <= 0) return;
    try {
      await _repo.addDebit(widget.projectId, amount, receiptPath, notes: notes.isEmpty ? null : notes);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('expense_debit', {
          'project_id': widget.projectId,
          'amount': amount,
          'notes': notes.isEmpty ? null : notes,
          'receipt_path': receiptPath,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved offline. Will sync when online.')));
          _load();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/project/${widget.projectId}'),
        ),
        title: const Text('Wallet'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 8),
                      Text('Balance', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _wallet != null ? '₹${_wallet!.balance.toStringAsFixed(2)}' : '—',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _addMoney,
                              icon: const Icon(Icons.add),
                              label: const Text('Add money'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _spendMoney,
                              icon: const Icon(Icons.remove),
                              label: const Text('Spend money'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Recent', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_wallet?.transactions.isEmpty ?? true)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No transactions yet.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        )
                      else
                        ...(_wallet!.transactions.take(20).map((t) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                t.type == 'credit' ? 'Added ₹${t.amount.toStringAsFixed(2)}' : 'Spent ₹${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: t.type == 'credit' ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                              subtitle: t.notes != null && t.notes!.isNotEmpty
                                  ? Text(t.notes!)
                                  : (t.createdAt != null ? Text(t.createdAt!) : null),
                            ))),
                    ],
                  ),
                ),
    );
  }
}
