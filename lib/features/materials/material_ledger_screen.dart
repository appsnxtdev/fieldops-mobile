import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'materials_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class MaterialLedgerScreen extends StatefulWidget {
  const MaterialLedgerScreen({
    super.key,
    required this.projectId,
    required this.materialId,
    this.material,
  });

  final String projectId;
  final String materialId;
  final MaterialWithBalance? material;

  @override
  State<MaterialLedgerScreen> createState() => _MaterialLedgerScreenState();
}

class _MaterialLedgerScreenState extends State<MaterialLedgerScreen> {
  final _repo = MaterialsRepository();
  final _syncRepo = SyncQueueRepository();

  List<LedgerEntry> _entries = [];
  bool _loading = true;
  bool _addingEntry = false;

  String get _materialName => widget.material?.name ?? 'Material';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.listLedger(widget.projectId, widget.materialId);
      if (mounted) setState(() => _entries = list);
    } catch (_) {
      if (mounted) setState(() => _entries = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _addEntry(String type) async {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    String? receiptPath;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(type == 'in' ? 'Add In' : 'Add Out'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
                  ),
                  if (type == 'in') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final x = await picker.pickImage(source: ImageSource.gallery);
                            if (x != null && ctx.mounted) setDialogState(() => receiptPath = x.path);
                          },
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: Text(receiptPath == null ? 'Attach receipt (optional)' : 'Receipt attached'),
                        ),
                        if (receiptPath != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setDialogState(() => receiptPath = null),
                            tooltip: 'Remove receipt',
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Add')),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final qtyStr = qtyController.text.trim();
    if (qtyStr.isEmpty) {
      _showToast('Quantity is required.');
      return;
    }
    final qty = double.tryParse(qtyStr);
    if (qty == null || qty <= 0) {
      _showToast('Enter a valid quantity.');
      return;
    }
    final notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
    if (!mounted) return;
    setState(() => _addingEntry = true);
    try {
      await _repo.addLedgerEntry(
        widget.projectId,
        widget.materialId,
        type: type,
        quantity: qty,
        notes: notes,
        receiptFilePath: type == 'in' ? receiptPath : null,
      );
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        await _load();
        if (mounted) _showToast('Entry added.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('material_ledger_entry', {
          'project_id': widget.projectId,
          'material_id': widget.materialId,
          'type': type,
          'quantity': qty,
          if (notes != null) 'notes': notes,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          await _load();
          if (mounted) _showToast('Saved offline. Will sync when online.');
        }
      } else {
        if (mounted) _showToast(userFacingMessage(e, context: 'Add entry'));
      }
    } catch (e) {
      if (mounted) _showToast(userFacingMessage(e, context: 'Add entry'));
    } finally {
      if (mounted) setState(() => _addingEntry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _addingEntry ? null : () => context.pop()),
        title: Text(_materialName),
      ),
      body: Stack(
        children: [
          _loading && _entries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _addingEntry ? null : () => _addEntry('in'),
                          icon: const Icon(Icons.add),
                          label: const Text('In'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _addingEntry ? null : () => _addEntry('out'),
                          icon: const Icon(Icons.remove),
                          label: const Text('Out'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No ledger entries yet.')),
                    )
                  else
                    ...[
                      for (final e in _entries)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              e.type == 'in' ? Icons.arrow_downward : Icons.arrow_upward,
                              color: e.type == 'in' ? Colors.green : Colors.orange,
                            ),
                            title: Text('${e.type == "in" ? "+" : "-"} ${e.quantity.toStringAsFixed(1)}'),
                            subtitle: e.notes != null ? Text(e.notes!) : (e.createdAt != null ? Text(_formatTime(e.createdAt!)) : null),
                            trailing: e.receiptPath != null ? const Icon(Icons.receipt_long, color: Colors.grey, size: 20) : null,
                          ),
                        ),
                    ],
                ],
              ),
            ),
          if (_addingEntry)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
