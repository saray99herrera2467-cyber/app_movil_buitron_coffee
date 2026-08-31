class ResenaModel {
  final int? id;
  final int productoId;
  final int usuarioId;
  final int calificacion;
  final String? comentario;
  final DateTime? fecha;
  final Map<String, dynamic>? usuario;

  ResenaModel({
    this.id,
    required this.productoId,
    required this.usuarioId,
    required this.calificacion,
    this.comentario,
    this.fecha,
    this.usuario,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: json['id'] as int?,
      productoId: json['producto_id'] as int,
      usuarioId: json['usuario_id'] as int,
      calificacion: json['calificacion'] as int,
      comentario: json['comentario'] as String?,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString())
          : null,
      usuario: json['usuario'] != null
          ? Map<String, dynamic>.from(json['usuario'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'usuario_id': usuarioId,
      'calificacion': calificacion,
      'comentario': comentario,
    };
  }
}