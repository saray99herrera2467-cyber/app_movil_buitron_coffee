class HistorialModel {
  final int id;
  final int usuarioId;
  final DateTime fecha;
  final double total;
  final String estado;

  HistorialModel({
    required this.id,
    required this.usuarioId,
    required this.fecha,
    required this.total,
    required this.estado,
  });

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    return HistorialModel(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toString()),
      total: (json['total'] ?? 0).toDouble(),
      estado: json['estado'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'fecha': fecha.toIso8601String(),
      'total': total,
      'estado': estado,
    };
  }
}