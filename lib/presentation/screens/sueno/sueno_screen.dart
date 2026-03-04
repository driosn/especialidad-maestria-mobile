import 'package:equilibra_mobile/presentation/cubits/sueno_cubit.dart';
import 'package:equilibra_mobile/presentation/cubits/sueno_state.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/register_sleep_sheet.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/sleep_periods_list.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/sueno_date_nav.dart';
import 'package:equilibra_mobile/presentation/screens/sueno/widgets/total_sleep_card.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuenoScreen extends StatelessWidget {
  const SuenoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SuenoView();
  }
}

class _SuenoView extends StatelessWidget {
  const _SuenoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sueño',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SuenoCubit, SuenoState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SuenoDateNav(
                  date: state.selectedDate,
                  onPrevious: () {
                    final d = state.selectedDate;
                    context.read<SuenoCubit>().setDate(
                      DateTime(d.year, d.month, d.day - 1),
                    );
                  },
                  onNext: () {
                    final d = state.selectedDate;
                    context.read<SuenoCubit>().setDate(
                      DateTime(d.year, d.month, d.day + 1),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SleepPeriodsList(
                  periods: state.sleepTimes,
                  onOptionsTap: (period) => _showOptions(context, period.id),
                ),
                const SizedBox(height: 16),
                TotalSleepCard(
                  title: _isToday(state.selectedDate)
                      ? 'Total de sueño hoy'
                      : 'Total de sueño',
                  totalFormatted: state.totalDurationFormatted,
                  periodCount: state.sleepTimes.length,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton.icon(
            onPressed: () => _onRegisterSleep(context),
            icon: const Icon(Icons.add, size: 22),
            label: const Text('Registrar período de sueño'),
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

  Future<void> _onRegisterSleep(BuildContext context) async {
    final state = context.read<SuenoCubit>().state;
    final ok = await showRegisterSleepSheet(
      context,
      state.selectedDate,
      ({
        required String name,
        required DateTime startTimestamp,
        required DateTime endTimestamp,
      }) => context.read<SuenoCubit>().registerSleepTime(
        name: name,
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
      ),
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Período de sueño registrado'),
          backgroundColor: AppColors.sleepPrimary,
        ),
      );
    }
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _showOptions(BuildContext context, String periodId) {
    final cubit = context.read<SuenoCubit>();
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
                cubit.deleteSleepTime(periodId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
