import 'producto.dart';

class Pedido {
  final String id;
  final List<Producto> productos;
  final DateTime fecha;
  final double total;
  String estado;
  String? numeroGuia;
  String? transportista;

  Pedido({
    required this.id,
    required this.productos,
    required this.fecha,
    required this.total,
    this.estado = 'pendiente',
    this.numeroGuia,
    this.transportista,
  });
}