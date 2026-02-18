import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_messages.dart';
import 'materials_repository.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _repo = MaterialsRepository();
  List<MaterialWithBalance> _materials = [];
  List<MasterMaterial> _masterMaterials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.listMaterials(widget.projectId);
      if (mounted) setState(() => _materials = list);
    } catch (_) {
      if (mounted) setState(() => _materials = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMasterMaterials() async {
    try {
      final list = await _repo.listMasterMaterials();
      if (mounted) setState(() => _masterMaterials = list);
    } catch (_) {
      if (mounted) setState(() => _masterMaterials = []);
    }
  }

  Future<void> _showAddMaterial() async {
    await _loadMasterMaterials();
    if (!mounted) return;
    bool fromCatalog = _masterMaterials.isNotEmpty;
    MasterMaterial? selectedMaster = _masterMaterials.isNotEmpty ? _masterMaterials.first : null;
    final customNameController = TextEditingController();
    String customUnit = materialUnits.first;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Add material', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('From catalog'),
                          selected: fromCatalog,
                          onSelected: (v) => setModalState(() => fromCatalog = v),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Custom'),
                          selected: !fromCatalog,
                          onSelected: (v) => setModalState(() => fromCatalog = !v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (fromCatalog) ...[
                      if (_masterMaterials.isEmpty)
                        const Text('No catalog items. Use Custom or add master materials in the web app.', style: TextStyle(fontSize: 12))
                      else
                        DropdownButtonFormField<MasterMaterial>(
                          value: selectedMaster,
                          decoration: const InputDecoration(labelText: 'Catalog item', border: OutlineInputBorder()),
                          items: _masterMaterials
                              .map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.unit})')))
                              .toList(),
                          onChanged: (m) => setModalState(() => selectedMaster = m),
                        ),
                    ] else ...[
                      TextField(
                        controller: customNameController,
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: customUnit,
                        decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                        items: materialUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setModalState(() => customUnit = v ?? materialUnits.first),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                        FilledButton(
                          onPressed: () {
                            if (fromCatalog && selectedMaster != null) {
                              Navigator.of(ctx).pop(<String, dynamic>{'master_material_id': selectedMaster!.id});
                            } else if (!fromCatalog && customNameController.text.trim().isNotEmpty) {
                              Navigator.of(ctx).pop(<String, dynamic>{
                                'name': customNameController.text.trim(),
                                'unit': customUnit,
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    try {
      if (result.containsKey('master_material_id')) {
        await _repo.createMaterial(widget.projectId, masterMaterialId: result['master_material_id'] as String);
      } else {
        await _repo.createMaterial(
          widget.projectId,
          name: result['name'] as String?,
          unit: result['unit'] as String?,
        );
      }
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingMessage(e, context: 'Add material')), behavior: SnackBarBehavior.floating),
        );
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
        title: const Text('Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMaterial,
            tooltip: 'Add material',
          ),
        ],
      ),
      body: _loading && _materials.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _materials.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No materials yet. Tap + to add from catalog or add a custom material.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final m = _materials[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(m.name),
                            subtitle: Text('${m.balance.toStringAsFixed(1)} ${m.unit}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              '/project/${widget.projectId}/materials/${m.id}',
                              extra: m,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
