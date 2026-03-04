import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/user_model.dart';

const String _usersCollection = 'users';

/// Servicio para la colección `users` en Firestore.
/// Schema: name (String), lastName (String), email (String), createdAt (DateTime).
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(_usersCollection);

  Future<void> setUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, Object?> data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> createUser({
    required String uid,
    required String name,
    required String lastName,
    required String email,
  }) async {
    final user = UserModel(
      id: uid,
      name: name,
      lastName: lastName,
      email: email,
      createdAt: DateTime.now(),
    );
    await setUser(user);
  }
}
