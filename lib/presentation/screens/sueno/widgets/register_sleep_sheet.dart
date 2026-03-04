import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

Future<bool> showRegisterSleepSheet(
  BuildContext context,
  DateTime selectedDate,
  void Function({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) onRegister,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RegisterSleepSheetContent(
      selectedDate: selectedDate,
      onRegister: onRegister,
    ),
  );
  return result ?? false;
}

class _RegisterSleepSheetContent extends StatefulWidget {
  const _RegisterSleepSheetContent({
    required this.selectedDate,
    required this.onRegister,
  });

  final DateTime selectedDate;
  final void Function({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) onRegister;

  @override
  State<_RegisterSleepSheetContent> createState() =>
      _RegisterSleepSheetContentState();
}

class _RegisterSleepSheetContentState extends State<_RegisterSleepSheetContent> {
  late final TextEditingController nameController;
  TimeOfDay _startTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'Sueño nocturno');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = widget.selectedDate;
    final onRegister = widget.onRegister;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                  Expanded(
                    child: Text(
                      'Registrar período de sueño',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Sueño nocturno, Siesta...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hora de inicio',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _formatTimeOfDay(_startTime),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      trailing: const Icon(Icons.access_time),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hora de fin',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _formatTimeOfDay(_endTime),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      trailing: const Icon(Icons.access_time),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Escribe un nombre para el período'),
                            ),
                          );
                          return;
                        }
                        final start = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          _startTime.hour,
                          _startTime.minute,
                        );
                        var end = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          _endTime.hour,
                          _endTime.minute,
                        );
                        if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
                          end = end.add(const Duration(days: 1));
                        }
                        onRegister(
                          name: name,
                          startTimestamp: start,
                          endTimestamp: end,
                        );
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sleepPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Registrar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
