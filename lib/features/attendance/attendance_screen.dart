import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth/app_user_state.dart';
import '../dashboard/projects_repository.dart';
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
  static const _radiusMeters = 100.0;

  /// Haversine distance in meters between two lat/lng points.
  static double _haversineMeters(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dphi = (lat2 - lat1) * math.pi / 180;
    final dlambda = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dphi / 2) * math.sin(dphi / 2) +
        math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) * math.sin(dlambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// Returns true if within _radiusMeters of project; if project has no lat/lng, allows (no check).
  Future<bool> _isWithinProjectRadius(Position position) async {
    final project = await ProjectsRepository().getProject(widget.projectId);
    if (project?.lat == null || project?.lng == null) return true;
    final dist = _haversineMeters(
      project!.lat!,
      project.lng!,
      position.latitude,
      position.longitude,
    );
    return dist <= _radiusMeters;
  }

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

  Future<Position?> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return null;
    if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return null;
    // Use cached position if available (fast); else get current with timeout so we don't hang
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return last;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 15),
    );
  }

  Future<String?> _captureSelfie() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return file?.path;
  }

  Future<void> _doCheckIn() async {
    _showToast('Getting location…');
    Position? position;
    try {
      position = await _getLocation();
    } on TimeoutException catch (_) {
      _showToast('Location timed out. Emulator: set mock location (⋮ → Location). Device: ensure GPS/location is on.', isError: true);
      return;
    } catch (e) {
      _showToast('Could not get location. Try again.', isError: true);
      return;
    }
    if (position == null) {
      _showToast('Location required. Turn on device location and allow permission for this app, then try again.', isError: true);
      return;
    }
    _showToast('Checking distance from project…');
    bool withinRadius;
    try {
      withinRadius = await _isWithinProjectRadius(position);
    } catch (e) {
      _showToast('Could not verify project location. Try again.', isError: true);
      return;
    }
    if (!mounted) return;
    if (!withinRadius) {
      _showToast('You must be within 100m of the project location to check in. Move closer and try again.', isError: true);
      return;
    }
    _showToast('Opening camera for selfie…');
    final selfiePath = await _captureSelfie();
    if (selfiePath == null || !mounted) {
      _showToast('Selfie is required for check-in.', isError: true);
      return;
    }
    try {
      await _repo.checkIn(widget.projectId, _today(), position.latitude, position.longitude, selfiePath);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        _showToast('Checked in successfully.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('attendance_check_in', {
          'project_id': widget.projectId,
          'date': _today(),
          'lat': position.latitude,
          'lng': position.longitude,
          'selfie_path': selfiePath,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          _load();
        }
      } else {
        _showToast(userFacingMessage(e, context: 'Check-in'), isError: true);
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Check-in'), isError: true);
    }
  }

  Future<void> _doCheckOut() async {
    _showToast('Getting location…');
    Position? position;
    try {
      position = await _getLocation();
    } on TimeoutException catch (_) {
      _showToast('Location timed out. Emulator: set mock location (⋮ → Location). Device: ensure GPS/location is on.', isError: true);
      return;
    } catch (e) {
      _showToast('Could not get location. Try again.', isError: true);
      return;
    }
    if (position == null) {
      _showToast('Location required. Turn on device location and allow permission for this app, then try again.', isError: true);
      return;
    }
    _showToast('Checking distance from project…');
    bool withinRadius;
    try {
      withinRadius = await _isWithinProjectRadius(position);
    } catch (e) {
      _showToast('Could not verify project location. Try again.', isError: true);
      return;
    }
    if (!mounted) return;
    if (!withinRadius) {
      _showToast('You must be within 100m of the project location to check out. Move closer and try again.', isError: true);
      return;
    }
    _showToast('Opening camera for selfie…');
    final selfiePath = await _captureSelfie();
    if (selfiePath == null || !mounted) {
      _showToast('Selfie is required for check-out.', isError: true);
      return;
    }
    try {
      await _repo.checkOut(widget.projectId, _today(), position.latitude, position.longitude, selfiePath);
      if (mounted) {
        context.read<SyncStatusNotifier>().refresh();
        _load();
        _showToast('Checked out successfully.');
      }
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _syncRepo.add('attendance_check_out', {
          'project_id': widget.projectId,
          'date': _today(),
          'lat': position.latitude,
          'lng': position.longitude,
          'selfie_path': selfiePath,
        });
        if (mounted) {
          context.read<SyncStatusNotifier>().refresh();
          _showToast('Saved offline. Will sync when online.');
          _load();
        }
      } else {
        _showToast(userFacingMessage(e, context: 'Check-out'), isError: true);
      }
    } catch (e) {
      _showToast(userFacingMessage(e, context: 'Check-out'), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today();
    final currentUserId = context.watch<AppUserState>().user?.id;
    final myRecord = currentUserId != null
        ? _list.where((r) => r.userId == currentUserId).firstOrNull
        : _list.isNotEmpty ? _list.first : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/project/${widget.projectId}'),
        ),
        title: const Text('Attendance'),
      ),
      body: _loading && _list.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(today, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  if (myRecord != null) ...[
                    if (myRecord.checkInAt != null)
                      ListTile(
                        leading: Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
                        title: const Text('Checked in'),
                        subtitle: Text(_formatTime(myRecord.checkInAt!)),
                      ),
                    if (myRecord.checkOutAt != null)
                      ListTile(
                        leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.secondary),
                        title: const Text('Checked out'),
                        subtitle: Text(_formatTime(myRecord.checkOutAt!)),
                      ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _doCheckIn,
                          icon: const Icon(Icons.login),
                          label: const Text('Check In'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _doCheckOut,
                          icon: const Icon(Icons.logout),
                          label: const Text('Check Out'),
                        ),
                      ),
                    ],
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
                          const SizedBox(height: 8),
                          Text(
                            'Check-in requires location and a selfie.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
