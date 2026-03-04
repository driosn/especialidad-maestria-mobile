import 'package:flutter/material.dart';
import 'package:equilibra_mobile/data/models/default_ingredient_model.dart';
import 'package:equilibra_mobile/presentation/theme/app_colors.dart';

Future<({String ingredientId, num quantity})?> showAddIngredientSheet(
  BuildContext context,
  List<DefaultIngredientModel> ingredients,
) async {
  if (ingredients.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Primero ejecuta el seed desde el FAB del Inicio')),
      );
    }
    return null;
  }

  DefaultIngredientModel? selected;
  final qtyController = TextEditingController(text: '1');
  final searchController = TextEditingController();
  String searchQuery = '';

  return showModalBottomSheet<({String ingredientId, num quantity})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final filtered = searchQuery.trim().isEmpty
            ? ingredients
            : ingredients
                .where((ing) =>
                    ing.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Cabecera: X a la izquierda, título centrado
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                        tooltip: 'Cerrar',
                      ),
                      Expanded(
                        child: Text(
                          'Agregar ingrediente',
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
                // Buscador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar ingrediente...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // Lista filtrada
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.trim().isEmpty
                                ? 'No hay ingredientes'
                                : 'Ningún resultado para "$searchQuery"',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final ing = filtered[index];
                            final isSelected = selected?.id == ing.id;
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.healthPrimaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 20,
                                  color: AppColors.healthPrimary,
                                ),
                              ),
                              title: Text(ing.name),
                              subtitle: Text(
                                '${ing.quantity} ${ing.unitTypeName} · ${ing.kcal} cal',
                              ),
                              selected: isSelected,
                              onTap: () => setState(() {
                                selected = ing;
                                qtyController.text = ing.quantity.toString();
                              }),
                            );
                          },
                        ),
                ),
                // Cantidad y botón Agregar abajo, bien separados
                if (selected != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: qtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Cantidad (${selected!.unitTypeName})',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            final qty = num.tryParse(qtyController.text);
                            if (qty == null || qty <= 0) return;
                            Navigator.pop(
                              context,
                              (ingredientId: selected!.id, quantity: qty),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.healthPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
