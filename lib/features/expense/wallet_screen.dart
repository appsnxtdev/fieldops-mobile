import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'expense_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

const String _currencySymbol = '₹';

class _WalletScreenState extends State<WalletScreen> {
  final _repo = ExpenseRepository();
  final _syncRepo = SyncQueueRepository();
  WalletData? _wallet;
  bool _loading = true;
  bool _saving = false;
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
        setState(() => _error = userFacingMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _viewReceiptPhoto(String pathOrUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenPhotoPage(pathOrUrl: pathOrUrl),
      ),
    );
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
    if (submitted != true || !mounted) return;
    final amount = double.tryParse(amountController.text.trim());
    final notes = notesController.text.trim();
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    try {
      await _repo.addCredit(widget.projectId, amount, notes: notes.isEmpty ? null : notes);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        await _load();
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
          await _load();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingMessage(e, context: 'Add money'))));
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
    if (source == null || !mounted) return;
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    final receiptPath = file.path;
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Spend money'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Receipt preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(receiptPath),
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.receipt_long, size: 48, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
    if (submitted != true || !mounted) return;
    final amount = double.tryParse(amountController.text.trim());
    final notes = notesController.text.trim();
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    try {
      await _repo.addDebit(widget.projectId, amount, receiptPath, notes: notes.isEmpty ? null : notes);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        await _load();
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
          await _load();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userFacingMessage(e, context: 'Spend money'))));
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _formatTransactionDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saving ? null : () => context.go('/project/${widget.projectId}'),
        ),
        title: const Text('Wallet'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _loading
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
                            _wallet != null ? '$_currencySymbol${_wallet!.balance.toStringAsFixed(2)}' : '—',
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
                                  onPressed: _saving ? null : _addMoney,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add money'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: _saving ? null : _spendMoney,
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
                                'No transactions yet. Add money or record spend with receipt.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ...(_wallet!.transactions.take(20).map((t) {
                              final isCredit = t.type == 'credit';
                              final color = isCredit ? AppColors.success : Theme.of(context).colorScheme.error;
                              final dateStr = _formatTransactionDate(t.createdAt);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    child: Icon(
                                      isCredit ? Icons.add : Icons.remove,
                                      color: color,
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    isCredit
                                        ? 'Added $_currencySymbol${t.amount.toStringAsFixed(2)}'
                                        : 'Spent $_currencySymbol${t.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (t.notes != null && t.notes!.isNotEmpty)
                                        Text(t.notes!, style: Theme.of(context).textTheme.bodySmall),
                                      if (dateStr.isNotEmpty)
                                        Text(
                                          dateStr,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                    ],
                                  ),
                                  trailing: !isCredit && t.receiptStoragePath != null
                                      ? IconButton(
                                          icon: Icon(Icons.receipt_long, color: color, size: 22),
                                          tooltip: 'View receipt',
                                          onPressed: () => _viewReceiptPhoto(t.receiptStoragePath!),
                                        )
                                      : null,
                                ),
                              );
                            })),
                        ],
                      ),
                    ),
          // Save loader overlay
          if (_saving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _FullScreenPhotoPage extends StatelessWidget {
  const _FullScreenPhotoPage({required this.pathOrUrl});

  final String pathOrUrl;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (pathOrUrl.startsWith('/') && File(pathOrUrl).existsSync()) {
      imageWidget = Image.file(File(pathOrUrl), fit: BoxFit.contain);
    } else {
      imageWidget = Image.network(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Receipt', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5.0,
          minScale: 0.5,
          child: imageWidget,
        ),
      ),
    );
  }
}
