class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;
  final String categoria;
  bool disponible;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.categoria,
    this.disponible = true,
  });
}