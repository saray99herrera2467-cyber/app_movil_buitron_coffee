class Resena {
  final String id;
  final String productoId;
  final String usuarioNombre;
  final int calificacion;
  final String comentario;
  final DateTime fecha;
  String? respuestaAdmin;

  Resena({
    required this.id,
    required this.productoId,
    required this.usuarioNombre,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
    this.respuestaAdmin,
  });
}