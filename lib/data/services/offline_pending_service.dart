import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equilibra_mobile/data/models/offline_pending_op_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _key = 'offline_pending';

/// Servicio que guarda en SharedPreferences las operaciones creadas sin conexión
/// y permite sincronizarlas manualmente con Firestore.
class OfflinePendingService {
  OfflinePendingService({
    SharedPreferences? prefs,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _prefs = prefs,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  SharedPreferences? _prefs;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<OfflinePendingOpModel>> getAll() async {
    final storage = await _storage;
    final list = storage.getStringList(_key);
    if (list == null || list.isEmpty) return [];
    return list
        .map((s) {
          try {
            final map = jsonDecode(s) as Map<String, dynamic>;
            return OfflinePendingOpModel.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<OfflinePendingOpModel>()
        .toList();
  }

  /// Añade una operación pendiente. [data] debe ser un JSON string con fechas en ISO8601.
  Future<void> addPending({
    required String id,
    required String type,
    required String collection,
    required String data,
  }) async {
    final storage = await _storage;
    final list = storage.getStringList(_key) ?? [];
    final op = OfflinePendingOpModel(
      id: id,
      type: type,
      collection: collection,
      data: data,
    );
    list.add(jsonEncode(op.toJson()));
    await storage.setStringList(_key, list);
  }

  Future<void> remove(String id) async {
    final all = await getAll();
    final rest = all.where((o) => o.id != id).toList();
    await _saveAll(rest);
  }

  Future<void> removeAll(Iterable<String> ids) async {
    final set = ids.toSet();
    final all = await getAll();
    final rest = all.where((o) => !set.contains(o.id)).toList();
    await _saveAll(rest);
  }

  Future<void> _saveAll(List<OfflinePendingOpModel> list) async {
    final storage = await _storage;
    await storage.setStringList(
      _key,
      list.map((o) => jsonEncode(o.toJson())).toList(),
    );
  }

  /// Pendientes de una colección, opcionalmente filtrados por fecha.
  /// [date] se usa para registeredMeals/registeredExercises/registeredSleepTimes (mismo día).
  /// [year] se usa para registeredMedicalVisits.
  Future<List<OfflinePendingOpModel>> getByCollection(
    String collection, {
    DateTime? date,
    int? year,
  }) async {
    final all = await getAll();
    final forCol = all.where((o) => o.collection == collection).toList();
    if (date != null) {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      return forCol.where((o) {
        final d = _dateFromPendingData(o.collection, o.data);
        return d != null && !d.isBefore(dayStart) && d.isBefore(dayEnd);
      }).toList();
    }
    if (year != null) {
      final start = DateTime(year, 1, 1);
      final end = DateTime(year + 1, 1, 1);
      return forCol.where((o) {
        final d = _dateFromPendingData(o.collection, o.data);
        return d != null && !d.isBefore(start) && d.isBefore(end);
      }).toList();
    }
    return forCol;
  }

  DateTime? _dateFromPendingData(String collection, String dataJson) {
    try {
      final map = jsonDecode(dataJson) as Map<String, dynamic>;
      if (collection == 'registeredMedicalVisits') {
        final v = map['createdAt'];
        if (v is String) return DateTime.tryParse(v);
        return null;
      }
      if (collection == 'registeredSleepTimes') {
        final v = map['startTimestamp'];
        if (v is String) return DateTime.tryParse(v);
        return null;
      }
      final v = map['date'] ?? map['createdAt'];
      if (v is String) return DateTime.tryParse(v);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parsea el JSON de data y convierte campos de fecha (string ISO) a DateTime para fromMap de modelos.
  static Map<String, dynamic> parseDataMap(String dataJson) {
    final map = jsonDecode(dataJson) as Map<String, dynamic>;
    return _mapDatesToDateTime(map);
  }

  static Map<String, dynamic> _mapDatesToDateTime(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    const dateKeys = ['date', 'createdAt', 'startTimestamp', 'endTimestamp'];
    for (final e in map.entries) {
      var v = e.value;
      if (dateKeys.contains(e.key) && v is String) {
        v = DateTime.tryParse(v) ?? v;
      } else if (v is Map) {
        v = _mapDatesToDateTime(Map<String, dynamic>.from(v));
      } else if (v is List) {
        v = v.map((x) => x is Map ? _mapDatesToDateTime(Map<String, dynamic>.from(x)) : x).toList();
      }
      out[e.key] = v;
    }
    return out;
  }

  /// Convierte un map con Timestamp/DateTime a map con fechas en ISO string para guardar en JSON.
  static Map<String, dynamic> mapToJsonSafe(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    for (final e in map.entries) {
      final v = e.value;
      if (v is Timestamp) {
        out[e.key] = v.toDate().toIso8601String();
      } else if (v is DateTime) {
        out[e.key] = v.toIso8601String();
      } else if (v is Map) {
        out[e.key] = mapToJsonSafe(Map<String, dynamic>.from(v));
      } else if (v is List) {
        out[e.key] = v.map((x) => x is Map ? mapToJsonSafe(Map<String, dynamic>.from(x)) : x).toList();
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }

  /// Convierte un map con fechas en ISO string a map con Timestamp para Firestore.
  static Map<String, dynamic> _dataToFirestore(Map<String, dynamic> map) {
    final out = Map<String, dynamic>.from(map);
    const dateKeys = [
      'date',
      'createdAt',
      'startTimestamp',
      'endTimestamp',
    ];
    for (final k in dateKeys) {
      if (!out.containsKey(k)) continue;
      final v = out[k];
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) out[k] = Timestamp.fromDate(dt);
      }
    }
    if (out['mealType'] is Map) {
      final mt = Map<String, dynamic>.from(out['mealType'] as Map);
      if (mt['createdAt'] is String) {
        final dt = DateTime.tryParse(mt['createdAt'] as String);
        if (dt != null) mt['createdAt'] = Timestamp.fromDate(dt);
      }
      out['mealType'] = mt;
    }
    if (out['ingredients'] is List) {
      out['ingredients'] = (out['ingredients'] as List).map((e) => e).toList();
    }
    return out;
  }

  /// Sincroniza una operación: escribe en Firestore y la elimina de pendientes.
  Future<void> syncOne(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Usuario no autenticado');

    final all = await getAll();
    final op = all.firstWhere((o) => o.id == id);
    final dataMap = jsonDecode(op.data) as Map<String, dynamic>;
    if (dataMap['userId'] == null || dataMap['userId'] == '') {
      dataMap['userId'] = uid;
    }
    final data = _dataToFirestore(dataMap);
    await _firestore.collection(op.collection).doc(op.id).set(data);
    await remove(id);
  }

  /// Sincroniza todas las operaciones pendientes (una por una).
  Future<int> syncAll() async {
    final all = await getAll();
    int done = 0;
    for (final op in all) {
      try {
        await syncOne(op.id);
        done++;
      } catch (_) {
        // deja el resto en pendiente
      }
    }
    return done;
  }
}
