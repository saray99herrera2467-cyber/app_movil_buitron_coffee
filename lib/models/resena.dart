class ResenaModel {
  final int? id;
  final int productoId;
  final int usuarioId;
  final int calificacion;
  final String? comentario;
  final DateTime? fecha;
  final String estado;
  final String? nombreUsuario;
  final Map<String, dynamic>? usuario;

  ResenaModel({
    this.id,
    required this.productoId,
    required this.usuarioId,
    this.nombreUsuario,
    required this.calificacion,
    this.comentario,
    this.fecha,
    this.estado = 'pendiente',
    this.usuario,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: json['id'] as int?,
      productoId: (json['producto_id'] ?? json['id_producto']) as int,
      usuarioId: (json['usuario_id'] ?? json['id_usuario']) as int,
      nombreUsuario: json['nombre_usuario'] as String?,
      calificacion: json['calificacion'] as int,
      comentario: json['comentario'] as String?,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString())
          : null,
      estado: json['estado']?.toString() ?? 'pendiente',
      usuario: json['usuario'] != null
          ? Map<String, dynamic>.from(json['usuario'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'usuario_id': usuarioId,
      'nombre_usuario': nombreUsuario,
      'calificacion': calificacion,
      'comentario': comentario,
      'estado': estado,
    };
  }
}