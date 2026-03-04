import 'package:flutter/material.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

Future<bool> showRegisterVisitSheet(
  BuildContext context,
  void Function({
    required String doctorName,
    required String field,
    required String title,
    required String description,
  }) onRegister,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RegisterVisitSheetContent(onRegister: onRegister),
  );
  return result ?? false;
}

class _RegisterVisitSheetContent extends StatefulWidget {
  const _RegisterVisitSheetContent({
    required this.onRegister,
  });

  final void Function({
    required String doctorName,
    required String field,
    required String title,
    required String description,
  }) onRegister;

  @override
  State<_RegisterVisitSheetContent> createState() =>
      _RegisterVisitSheetContentState();
}

class _RegisterVisitSheetContentState extends State<_RegisterVisitSheetContent> {
  late final TextEditingController doctorNameController;
  late final TextEditingController fieldController;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    doctorNameController = TextEditingController();
    fieldController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    doctorNameController.dispose();
    fieldController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onRegister = widget.onRegister;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
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
                      'Registrar visita médica',
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
                      controller: doctorNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del doctor',
                        hintText: 'Dr. María González',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fieldController,
                      decoration: InputDecoration(
                        labelText: 'Especialidad médica',
                        hintText: 'Medicina General, Cardiología...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Título de la cita',
                        hintText: 'Revisión anual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción y detalles',
                        hintText: 'Control de presión arterial...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        final doctorName = doctorNameController.text.trim();
                        if (doctorName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Escribe el nombre del doctor'),
                            ),
                          );
                          return;
                        }
                        onRegister(
                          doctorName: doctorName,
                          field: fieldController.text.trim(),
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                        );
                        Navigator.pop(context, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
}
