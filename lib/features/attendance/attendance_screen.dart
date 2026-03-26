import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/app_user_state.dart';
import 'attendance_repository.dart';
import '../../core/errors/user_facing_messages.dart';
import '../../core/storage/sync_queue_repository.dart';
import '../../core/sync/sync_status_notifier.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _repo = AttendanceRepository();
  final _syncRepo = SyncQueueRepository();
  final _picker = ImagePicker();

  List<AttendanceRecord> _list = [];
  bool _loading = true;
  bool _submitting = false;

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.listAttendance(widget.projectId, _today());
      if (mounted) {
        setState(() => _list = list);
      }
    } catch (e) {
      // Error surfaced via snackbar if needed; list stays empty
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

  static const _snackDuration = Duration(seconds: 8);

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        duration: _snackDuration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  /// Fetches the current GPS location. Requests permission if needed.
  /// Returns null only if location services are disabled or permission denied.
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) _showToast('Location services are disabled. Checking in without location.', isError: false);
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          (permission != LocationPermission.whileInUse && permission != LocationPermission.always)) {
        if (mounted) _showToast('Location permission denied. Checking in without location.', isError: false);
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _captureSelfie() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return file?.path;
  }

  Future<void> _doCheckIn() async {
    setState(() => _submitting = true);
    try {
      _showToast('Opening camera for selfie…');
      final selfiePath = await _captureSelfie();
      if (selfiePath == null || !mounted) {
        _showToast('Selfie is required for check-in.', isError: true);
        return;
      }
      if (mounted) _showToast('Getting your location…');
      final position = await _getCurrentLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;
      try {
        await _repo.checkIn(widget.projectId, _today(), selfiePath, lat: lat, lng: lng);
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          await _load();
          _showToast('Checked in successfully.');
        }
      } on DioException catch (e) {
        if (_isNetworkError(e)) {
          await _syncRepo.add('attendance_check_in', {
            'project_id': widget.projectId,
            'date': _today(),
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
            'selfie_path': selfiePath,
          });
          if (mounted) {
            context.read<SyncStatusNotifier>().refresh();
            _showToast('Saved offline. Will sync when online.');
            await _load();
          }
        } else {
          if (mounted) _showToast(userFacingMessage(e, context: 'Check-in'), isError: true);
        }
      } catch (e) {
        if (mounted) _showToast(userFacingMessage(e, context: 'Check-in'), isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _doCheckOut() async {
    setState(() => _submitting = true);
    try {
      _showToast('Opening camera for selfie…');
      final selfiePath = await _captureSelfie();
      if (selfiePath == null || !mounted) {
        _showToast('Selfie is required for check-out.', isError: true);
        return;
      }
      if (mounted) _showToast('Getting your location…');
      final position = await _getCurrentLocation();
      final lat = position?.latitude;
      final lng = position?.longitude;
      try {
        await _repo.checkOut(widget.projectId, _today(), selfiePath, lat: lat, lng: lng);
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          await _load();
          _showToast('Checked out successfully.');
        }
      } on DioException catch (e) {
        if (_isNetworkError(e)) {
          await _syncRepo.add('attendance_check_out', {
            'project_id': widget.projectId,
            'date': _today(),
            if (lat != null) 'lat': lat,
            if (lng != null) 'lng': lng,
            'selfie_path': selfiePath,
          });
          if (mounted) {
            context.read<SyncStatusNotifier>().refresh();
            _showToast('Saved offline. Will sync when online.');
            await _load();
          }
        } else {
          if (mounted) _showToast(userFacingMessage(e, context: 'Check-out'), isError: true);
        }
      } catch (e) {
        if (mounted) _showToast(userFacingMessage(e, context: 'Check-out'), isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today();
    final currentUserId = context.watch<AppUserState>().user?.id;
    final myRecord = currentUserId != null
        ? _list.where((r) => r.userId == currentUserId).firstOrNull
        : _list.isNotEmpty ? _list.first : null;

    final alreadyCheckedIn = myRecord?.checkInAt != null;
    final alreadyCheckedOut = myRecord?.checkOutAt != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : () => context.go('/project/${widget.projectId}'),
        ),
        title: const Text('Attendance'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _loading && _list.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(today, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      // My attendance status cards
                      if (alreadyCheckedIn) ...[
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: ListTile(
                            leading: Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
                            title: const Text('Checked in'),
                            subtitle: Text(_formatTime(myRecord!.checkInAt!)),
                            trailing: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (alreadyCheckedOut) ...[
                        Card(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.secondary),
                            title: const Text('Checked out'),
                            subtitle: Text(_formatTime(myRecord!.checkOutAt!)),
                            trailing: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              // Disabled if already checked in OR currently submitting
                              onPressed: (alreadyCheckedIn || _submitting) ? null : _doCheckIn,
                              icon: const Icon(Icons.login),
                              label: Text(alreadyCheckedIn ? 'Checked In ✓' : 'Check In'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              // Disabled if not checked in, already checked out, or submitting
                              onPressed: (!alreadyCheckedIn || alreadyCheckedOut || _submitting) ? null : _doCheckOut,
                              icon: const Icon(Icons.logout),
                              label: Text(alreadyCheckedOut ? 'Checked Out ✓' : 'Check Out'),
                            ),
                          ),
                        ],
                      ),
                      if (!alreadyCheckedIn)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Check-in requires a selfie photo.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        "Who's on site today",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_list.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'No one checked in yet today.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._list.map((r) => Card(
                              child: ListTile(
                                leading: Icon(
                                  r.checkOutAt != null ? Icons.check_circle : Icons.radio_button_checked,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(r.displayName),
                                subtitle: Text(
                                  r.checkInAt != null
                                      ? (r.checkOutAt != null
                                          ? 'In ${_formatTime(r.checkInAt!)} · Out ${_formatTime(r.checkOutAt!)}'
                                          : 'In ${_formatTime(r.checkInAt!)}')
                                      : '—',
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
          if (_submitting)
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
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
