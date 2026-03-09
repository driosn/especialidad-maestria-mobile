import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/registered_sleep_time_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _collection = 'registeredSleepTimes';

class RegisteredSleepTimesService {
  RegisteredSleepTimesService({
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

  /// Períodos que empiezan en el día [date].
  Future<List<RegisteredSleepTimeModel>> getByDate(DateTime date) async {
    final uid = _userId;
    if (uid == null) return [];

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('startTimestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTimestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('startTimestamp')
        .get();

    final list = snap.docs
        .map((d) => RegisteredSleepTimeModel.fromMap(d.id, d.data()))
        .toList();
    list.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    return list;
  }

  Stream<List<RegisteredSleepTimeModel>> watchByDate(DateTime date) {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _col
        .where('userId', isEqualTo: uid)
        .where('startTimestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTimestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('startTimestamp')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => RegisteredSleepTimeModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
          return list;
        });
  }

  Future<String> create({
    required String name,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    final uid = _userId;
    if (uid == null) throw StateError('User not logged in');

    final ref = _col.doc();
    final now = DateTime.now();

    await ref.set({
      'userId': uid,
      'name': name,
      'startTimestamp': Timestamp.fromDate(startTimestamp),
      'endTimestamp': Timestamp.fromDate(endTimestamp),
      'createdAt': Timestamp.fromDate(now),
    });
    return ref.id;
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
