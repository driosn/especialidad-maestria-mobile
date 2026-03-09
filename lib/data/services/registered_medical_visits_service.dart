import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/registered_medical_visit_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _collection = 'registeredMedicalVisits';

class RegisteredMedicalVisitsService {
  RegisteredMedicalVisitsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collection);

  String? get _userId => _auth.currentUser?.uid;
  String? get currentUserId => _userId;

  /// Visitas del usuario ordenadas por fecha (más reciente primero).
  Future<List<RegisteredMedicalVisitModel>> getAll() async {
    final uid = _userId;
    if (uid == null) return [];

    final snap = await _col
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => RegisteredMedicalVisitModel.fromMap(d.id, d.data()))
        .toList();
  }

  /// Visitas de un año para el resumen.
  Future<List<RegisteredMedicalVisitModel>> getByYear(int year) async {
    final uid = _userId;
    if (uid == null) return [];

    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => RegisteredMedicalVisitModel.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<List<RegisteredMedicalVisitModel>> watchAll() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RegisteredMedicalVisitModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<String> create({
    required String doctorName,
    required String field,
    required String title,
    required String description,
  }) async {
    final uid = _userId;
    if (uid == null) throw StateError('User not logged in');

    final ref = _col.doc();
    final now = DateTime.now();

    await ref.set({
      'userId': uid,
      'doctorName': doctorName,
      'field': field,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(now),
    });
    return ref.id;
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
