import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de comida. Colección: mealTypes.
class MealTypeModel {
  final String id;
  final String name;
  final String iconSrc;
  final String color;
  final DateTime createdAt;

  const MealTypeModel({
    required this.id,
    required this.name,
    required this.iconSrc,
    required this.color,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'iconSrc': iconSrc,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MealTypeModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return MealTypeModel(
      id: id,
      name: map['name'] as String? ?? '',
      iconSrc: map['iconSrc'] as String? ?? '',
      color: map['color'] as String? ?? '#22C55E',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
    );
  }
}
