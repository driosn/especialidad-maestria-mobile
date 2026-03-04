import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/default_ingredient_model.dart';

const String _collection = 'defaultIngredients';

class DefaultIngredientsService {
  DefaultIngredientsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  Future<List<DefaultIngredientModel>> getAll() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => DefaultIngredientModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<DefaultIngredientModel?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return DefaultIngredientModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Seed con ~50 ingredientes de prueba (solo si la colección está vacía).
  Future<void> seed() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    final items = [
      ('Tostadas integrales', 'g', 'gramos', 100, 260, 48, 9),
      ('Aguacate', 'unidad', 'unidad', 1, 240, 13, 3),
      ('Pollo a la plancha', 'g', 'gramos', 100, 165, 0, 31),
      ('Arroz integral', 'g', 'gramos', 100, 370, 78, 8),
      ('Salmón al horno', 'g', 'gramos', 100, 208, 0, 20),
      ('Huevo', 'unidad', 'unidad', 1, 78, 0.6, 6),
      ('Leche', 'ml', 'mililitros', 100, 42, 5, 3.4),
      ('Avena', 'g', 'gramos', 100, 389, 66, 17),
      ('Plátano', 'unidad', 'unidad', 1, 105, 27, 1.3),
      ('Manzana', 'unidad', 'unidad', 1, 95, 25, 0.5),
      ('Pechuga de pavo', 'g', 'gramos', 100, 135, 0, 30),
      ('Brócoli', 'g', 'gramos', 100, 34, 7, 2.8),
      ('Zanahoria', 'g', 'gramos', 100, 41, 10, 0.9),
      ('Espinaca', 'g', 'gramos', 100, 23, 3.6, 2.9),
      ('Tomate', 'g', 'gramos', 100, 18, 3.9, 0.9),
      ('Papa', 'g', 'gramos', 100, 77, 17, 2),
      ('Batata', 'g', 'gramos', 100, 86, 20, 1.6),
      ('Quinoa', 'g', 'gramos', 100, 120, 21, 4.4),
      ('Pasta integral', 'g', 'gramos', 100, 348, 75, 13),
      ('Pan integral', 'rebanada', 'rebanada', 1, 81, 14, 4),
      ('Yogur natural', 'g', 'gramos', 100, 59, 3.5, 10),
      ('Queso cottage', 'g', 'gramos', 100, 98, 3.4, 11),
      ('Atún al natural', 'g', 'gramos', 100, 116, 0, 26),
      ('Lentejas', 'g', 'gramos', 100, 116, 20, 9),
      ('Garbanzos', 'g', 'gramos', 100, 164, 27, 9),
      ('Almendras', 'g', 'gramos', 100, 579, 22, 21),
      ('Nueces', 'g', 'gramos', 100, 654, 14, 15),
      ('Aceite de oliva', 'ml', 'mililitros', 15, 119, 0, 0),
      ('Miel', 'g', 'gramos', 100, 304, 82, 0),
      ('Mantequilla de maní', 'g', 'gramos', 100, 588, 20, 25),
      ('Jamón serrano', 'g', 'gramos', 100, 273, 1, 24),
      ('Tofu', 'g', 'gramos', 100, 76, 1.9, 8),
      ('Edamame', 'g', 'gramos', 100, 122, 10, 11),
      ('Remolacha', 'g', 'gramos', 100, 43, 10, 1.6),
      ('Calabacín', 'g', 'gramos', 100, 17, 3.1, 1.2),
      ('Pimiento', 'g', 'gramos', 100, 31, 6, 1),
      ('Cebolla', 'g', 'gramos', 100, 40, 9, 1.1),
      ('Ajo', 'diente', 'diente', 1, 4, 1, 0.2),
      ('Pera', 'unidad', 'unidad', 1, 102, 27, 0.6),
      ('Fresas', 'g', 'gramos', 100, 32, 8, 0.7),
      ('Arándanos', 'g', 'gramos', 100, 57, 14, 0.7),
      ('Uvas', 'g', 'gramos', 100, 69, 18, 0.7),
      ('Naranja', 'unidad', 'unidad', 1, 62, 15, 1.2),
      ('Kiwi', 'unidad', 'unidad', 1, 42, 10, 0.8),
      ('Sandía', 'g', 'gramos', 100, 30, 8, 0.6),
      ('Melón', 'g', 'gramos', 100, 34, 8, 0.8),
      ('Pavo molido', 'g', 'gramos', 100, 170, 0, 20),
      ('Ternera', 'g', 'gramos', 100, 250, 0, 26),
      ('Cerdo magro', 'g', 'gramos', 100, 143, 0, 21),
      ('Bacalao', 'g', 'gramos', 100, 82, 0, 18),
      ('Tilapia', 'g', 'gramos', 100, 96, 0, 20),
      ('Camarones', 'g', 'gramos', 100, 99, 0.2, 24),
    ];

    for (var i = 0; i < items.length; i++) {
      final (name, unitType, unitTypeName, quantity, kcal, carbs, proteins) =
          items[i];
      final ref = _col.doc();
      batch.set(ref, {
        'name': name,
        'unitType': unitType,
        'unitTypeName': unitTypeName,
        'quantity': quantity.toDouble(),
        'kcal': kcal.toDouble(),
        'carbs': carbs.toDouble(),
        'proteins': proteins.toDouble(),
        'createdAt': Timestamp.fromDate(now),
      });
    }

    await batch.commit();
  }
}
