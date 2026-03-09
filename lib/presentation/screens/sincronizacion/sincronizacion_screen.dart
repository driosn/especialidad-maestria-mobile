import 'package:equilibra_mobile/data/models/offline_pending_op_model.dart';
import 'package:equilibra_mobile/data/services/offline_pending_service.dart';
import 'package:equilibra_mobile/di/injection.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Pantalla para sincronizar manualmente los registros creados sin conexión.
class SincronizacionScreen extends StatefulWidget {
  const SincronizacionScreen({super.key});

  @override
  State<SincronizacionScreen> createState() => _SincronizacionScreenState();
}

class _SincronizacionScreenState extends State<SincronizacionScreen> {
  List<OfflinePendingOpModel> _pending = [];
  bool _loading = true;
  bool _syncing = false;
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
      final list = await getIt<OfflinePendingService>().getAll();
      if (mounted) {
        setState(() {
          _pending = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _syncOne(OfflinePendingOpModel op) async {
    setState(() => _syncing = true);
    try {
      await getIt<OfflinePendingService>().syncOne(op.id);
      if (mounted) await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _syncAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar todo'),
        content: Text(
          '¿Quieres sincronizar los ${_pending.length} registro(s) pendiente(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sincronizar todo'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _syncing = true);
    try {
      final done = await getIt<OfflinePendingService>().syncAll();
      if (mounted) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sincronizados: $done'),
            backgroundColor: AppColors.healthPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _collectionLabel(String collection) {
    switch (collection) {
      case 'registeredMeals':
        return 'Comida';
      case 'registeredExercises':
        return 'Ejercicio';
      case 'registeredSleepTimes':
        return 'Sueño';
      case 'registeredMedicalVisits':
        return 'Cita médica';
      default:
        return collection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sincronización',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
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
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _pending.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay registros pendientes de sincronizar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_pending.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _syncing ? null : _syncAll,
                          icon: _syncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                            _syncing
                                ? 'Sincronizando...'
                                : 'Sincronizar todo (${_pending.length})',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ..._pending.map(
                    (op) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(
                            Icons.cloud_off,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        title: Text(
                          _collectionLabel(op.collection),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'ID: ${op.id.length > 12 ? '${op.id.substring(0, 12)}...' : op.id}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: _syncing
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () => _syncOne(op),
                                child: const Text('Sincronizar'),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
