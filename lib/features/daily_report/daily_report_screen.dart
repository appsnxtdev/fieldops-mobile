import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'daily_report_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

/// Copy picked image to a persistent path so it survives for sync when offline.
Future<String> _persistPhotoPath(String pickedPath) async {
  final dir = await getApplicationDocumentsDirectory();
  final photosDir = Directory('${dir.path}/daily_report_photos');
  if (!await photosDir.exists()) await photosDir.create(recursive: true);
  final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final dest = File('${photosDir.path}/$name');
  await File(pickedPath).copy(dest.path);
  return dest.path;
}

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
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            message,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimary),
          ),
        ),
        duration: _snackDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static String _dateToString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _todayString() => _dateToString(DateTime.now());

  bool get _isToday => _reportDate == _todayString();

  @override
  void initState() {
    super.initState();
    _reportDate = _todayString();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getEntries(widget.projectId, _reportDate);
      if (mounted) setState(() => _entries = list);
    } catch (e) {
      if (mounted) {
        setState(() => _entries = []);
        _showToast(userFacingMessage(e));
      }
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
    if (!_isToday) {
      _showToast('You can only add entries for today. Select today\'s date to add.');
      return;
    }
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
        _showToast(userFacingMessage(e, context: 'Add note'));
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Add note'));
    }
  }

  Future<void> _addPhoto() async {
    if (!_isToday) {
      _showToast('You can only add entries for today. Select today\'s date to add.');
      return;
    }
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file == null || !mounted) return;
    String path;
    try {
      path = await _persistPhotoPath(file.path);
    } catch (e) {
      path = file.path;
    }
    if (!mounted) return;
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
        _showToast(userFacingMessage(e, context: 'Add photo'));
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Add photo'));
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
                  if (!_isToday)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'View only. You can only add entries for today.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isToday ? _addNote : null,
                          icon: const Icon(Icons.note_add),
                          label: const Text('Add note'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _isToday ? _addPhoto : null,
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
                      child: Column(
                        children: [
                          Text(
                            'No entries for this date. Tap \'Add note\' or \'Add photo\' to add.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._entries.map((e) {
                      if (e.type == 'note') {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.note_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.content, style: Theme.of(context).textTheme.bodyMedium),
                                      if (e.createdAt != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            _formatTime(e.createdAt!),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _thumbnail(e.content),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Photo', style: Theme.of(context).textTheme.bodyMedium),
                                    if (e.createdAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _formatTime(e.createdAt!),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    return Icon(Icons.photo_outlined, color: Theme.of(context).colorScheme.primary, size: 40);
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
