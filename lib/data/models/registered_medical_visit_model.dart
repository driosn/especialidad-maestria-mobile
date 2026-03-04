import 'package:cloud_firestore/cloud_firestore.dart';

/// Cita médica registrada. Colección: registeredMedicalVisits.
class RegisteredMedicalVisitModel {
  final String id;
  final String userId;
  final String doctorName;
  final String field; // Especialidad médica
  final String title; // Título de la cita
  final String description; // Descripción y detalles
  final DateTime createdAt;

  const RegisteredMedicalVisitModel({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.field,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'doctorName': doctorName,
      'field': field,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RegisteredMedicalVisitModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return RegisteredMedicalVisitModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? '',
      field: map['field'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
    );
  }
}
