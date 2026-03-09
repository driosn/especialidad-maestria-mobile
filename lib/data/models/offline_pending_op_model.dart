/// Operación pendiente de sincronización (creación offline).
class OfflinePendingOpModel {
  const OfflinePendingOpModel({
    required this.id,
    required this.type,
    required this.collection,
    required this.data,
  });

  final String id;
  final String type;
  final String collection;
  /// JSON string del documento a enviar (fechas en ISO8601).
  final String data;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'collection': collection,
        'data': data,
      };

  factory OfflinePendingOpModel.fromJson(Map<String, dynamic> json) {
    return OfflinePendingOpModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'POST',
      collection: json['collection'] as String? ?? '',
      data: json['data'] as String? ?? '{}',
    );
  }
}
