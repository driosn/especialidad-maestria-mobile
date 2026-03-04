import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de usuario para la colección `users` en Firestore.
/// Schema: name, lastName, email, createdAt
class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : (createdAt is DateTime ? createdAt : DateTime.now()),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? lastName,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
