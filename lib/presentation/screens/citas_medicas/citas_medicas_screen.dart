import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/visitas_medicas_state.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/widgets/register_visit_sheet.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/widgets/visitas_list.dart';
import 'package:equilibra_mobile/presentation/screens/citas_medicas/widgets/visitas_resumen_card.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitasMedicasScreen extends StatelessWidget {
  const CitasMedicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CitasMedicasView();
  }
}

class _CitasMedicasView extends StatelessWidget {
  const _CitasMedicasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Visitas Médicas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<VisitasMedicasCubit, VisitasMedicasState>(
        builder: (context, state) {
          if (state.loading && state.visits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<VisitasMedicasCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VisitasResumenCard(
                    year: state.selectedYear,
                    totalVisits: state.totalVisits,
                    specialistsCount: state.specialistsCount,
                    followUpsCount: state.followUpsCount,
                    onPreviousYear: () => context
                        .read<VisitasMedicasCubit>()
                        .setYear(state.selectedYear - 1),
                    onNextYear: () => context
                        .read<VisitasMedicasCubit>()
                        .setYear(state.selectedYear + 1),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Historial de visitas',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  VisitasList(
                    visits: state.visits,
                    pendingVisitIds: state.pendingVisitIds,
                    onOptionsTap: (visit) => _showOptions(context, visit.id),
                    onSyncTap: (id) => _onSyncVisitTap(context, id),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            onPressed: () => _onRegisterVisit(context),
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Registrar visita médica'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSyncVisitTap(BuildContext context, String visitId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar registro'),
        content: const Text('¿Quieres sincronizar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<VisitasMedicasCubit>().syncPendingVisit(visitId);
    }
  }

  Future<void> _onRegisterVisit(BuildContext context) async {
    final ok = await showRegisterVisitSheet(
      context,
      ({
        required String doctorName,
        required String field,
        required String title,
        required String description,
      }) => context.read<VisitasMedicasCubit>().registerVisit(
            doctorName: doctorName,
            field: field,
            title: title,
            description: description,
          ),
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visita médica registrada'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showOptions(BuildContext context, String visitId) {
    final cubit = context.read<VisitasMedicasCubit>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                cubit.deleteVisit(visitId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
