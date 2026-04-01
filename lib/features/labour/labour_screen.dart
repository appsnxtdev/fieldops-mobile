import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fieldops_mobile/core/sync/sync_status_notifier.dart';
import 'package:fieldops_mobile/features/labour/labour_repository.dart';
import 'package:fieldops_mobile/features/labour/labour_type.dart';
import 'package:fieldops_mobile/features/labour/labour_daily_entry.dart';

class LabourScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const LabourScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  final LabourRepository _repository = LabourRepository();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('EEEE, MMMM d, yyyy');

  List<LabourType>? _labourTypes;
  Map<String, int> _counts = {}; // labour_type_id -> count
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load labour types and daily entries in parallel
      print('Loading labour types and daily entries...');

      List<LabourType> labourTypes;
      List<LabourDailyEntry> dailyEntries;

      try {
        labourTypes = await _repository.getLabourTypes();
        print('Labour types loaded: ${labourTypes.length}');
      } catch (e) {
        print('Error loading labour types: $e');
        rethrow;
      }

      try {
        dailyEntries = await _repository.getLabourDaily(
          projectId: widget.projectId,
          date: _dateFormat.format(_selectedDate),
        );
        print('Daily entries loaded: ${dailyEntries.length}');
      } catch (e) {
        print('Error loading daily entries: $e');
        rethrow;
      }

      // Build counts map from daily entries
      final counts = <String, int>{};
      for (final entry in dailyEntries) {
        counts[entry.labourTypeId] = entry.count;
      }

      setState(() {
        _labourTypes = labourTypes;
        _counts = counts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _loadData: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = 'Failed to load labour data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLabour() async {
    if (!_isToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only update labour for today'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Build entries array (only include non-zero counts)
      final entries = _counts.entries
          .where((e) => e.value > 0)
          .map((e) => {
                'labour_type_id': e.key,
                'count': e.value,
              })
          .toList();

      await _repository.upsertLabourDaily(
        projectId: widget.projectId,
        date: _dateFormat.format(_selectedDate),
        entries: entries,
      );

      if (mounted) {
        final syncStatus = context.read<SyncStatusNotifier>();
        final message = syncStatus.isOnline
            ? 'Labour saved successfully'
            : 'Labour saved (will sync when online)';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save labour: $e';
        _isSaving = false;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadData();
  }

  void _updateCount(String labourTypeId, int delta) {
    if (!_isToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only update labour for today'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      final current = _counts[labourTypeId] ?? 0;
      final newValue = current + delta;
      if (newValue >= 0) {
        _counts[labourTypeId] = newValue;
      }
    });
  }

  void _setCount(String labourTypeId, String value) {
    if (!_isToday) return;

    final count = int.tryParse(value) ?? 0;
    setState(() {
      _counts[labourTypeId] = count >= 0 ? count : 0;
    });
  }

  double _calculateTotal() {
    if (_labourTypes == null) return 0.0;

    double total = 0.0;
    for (final type in _labourTypes!) {
      final count = _counts[type.id] ?? 0;
      total += count * type.ratePerDay;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Labour', style: TextStyle(fontSize: 18)),
            Text(
              widget.projectName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          if (!_isToday)
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: _goToToday,
              tooltip: 'Go to today',
            ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _displayDateFormat.format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isToday)
                        const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),

          // Total and Save button
          if (!_isLoading && _labourTypes != null && _labourTypes!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${_calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (_isToday) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveLabour,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Save Labour'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_labourTypes == null || _labourTypes!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No labour types available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask your admin to add labour types',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _labourTypes!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final type = _labourTypes![index];
        final count = _counts[type.id] ?? 0;
        final amount = count * type.ratePerDay;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${type.ratePerDay.toStringAsFixed(2)} per day',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Count:',
                      style: TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _isToday ? () => _updateCount(type.id, -1) : null,
                          color: _isToday ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            enabled: _isToday,
                            controller: TextEditingController(text: count.toString())
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: count.toString().length),
                              ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) => _setCount(type.id, value),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _isToday ? () => _updateCount(type.id, 1) : null,
                          color: _isToday ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
