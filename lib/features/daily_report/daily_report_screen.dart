import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'daily_report_repository.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final _repo = DailyReportRepository();
  final _syncRepo = SyncQueueRepository();
  final _picker = ImagePicker();

  List<DailyReportEntry> _entries = [];
  bool _loading = true;
  String _reportDate = '';

  static const _snackDuration = Duration(seconds: 6);

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        duration: _snackDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepOrange.shade700,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static String _dateToString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _reportDate = _dateToString(DateTime.now());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getEntries(widget.projectId, _reportDate);
      if (mounted) setState(() => _entries = list);
    } catch (e) {
      if (mounted) setState(() => _entries = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return e.message;
  }

  bool _isNetworkError(Object e) {
    return e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate.isEmpty ? now : DateTime.parse(_reportDate),
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _reportDate = _dateToString(picked));
      _load();
    }
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter note…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (submitted != true || !mounted) return;
    final text = controller.text.trim();
    if (text.isEmpty) {
      _showToast('Note cannot be empty.');
      return;
    }
    try {
      await _repo.addNote(widget.projectId, _reportDate, text, sortOrder: _entries.length);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        _showToast('Note added.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('daily_report_note', {
          'project_id': widget.projectId,
          'report_date': _reportDate,
          'content': text,
          'sort_order': _entries.length,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          _load();
        }
      } else {
        _showToast(_errorMessage(e) ?? 'Failed to add note');
      }
    } catch (e) {
      _showToast('Failed: ${e.toString()}');
    }
  }

  Future<void> _addPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null || !mounted) return;
    final path = file.path;
    try {
      await _repo.addPhoto(widget.projectId, _reportDate, path, sortOrder: _entries.length);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        _showToast('Photo added.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('daily_report_photo', {
          'project_id': widget.projectId,
          'report_date': _reportDate,
          'photo_path': path,
          'sort_order': _entries.length,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          _load();
        }
      } else {
        _showToast(_errorMessage(e) ?? 'Failed to add photo');
      }
    } catch (e) {
      _showToast('Failed: ${e.toString()}');
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
        title: const Text('Daily Report'),
      ),
      body: _loading && _entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_reportDate),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _addNote,
                          icon: const Icon(Icons.note_add),
                          label: const Text('Add note'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _addPhoto,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add photo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No entries for this date. Add a note or photo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  else
                    ..._entries.map((e) {
                      if (e.type == 'note') {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.note, color: Colors.amber),
                            title: Text(e.content),
                            subtitle: e.createdAt != null ? Text(_formatTime(e.createdAt!)) : null,
                          ),
                        );
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _thumbnail(e.content),
                          title: const Text('Photo'),
                          subtitle: e.createdAt != null ? Text(_formatTime(e.createdAt!)) : null,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _thumbnail(String pathOrUrl) {
    if (pathOrUrl.startsWith('/') && File(pathOrUrl).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(pathOrUrl), width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    return const Icon(Icons.photo, color: Colors.teal, size: 40);
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
