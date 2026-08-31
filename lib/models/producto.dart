class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagen;
  final String categoria;
  final bool estado;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagen,
    required this.categoria,
    required this.estado,
  });

  // ✅ CONVERTIR DESDE JSON DE SUPABASE
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre_producto'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'],
      categoria: json['categoria'] ?? 'General',
      estado: json['estado'] ?? true,
    );
  }

  // ✅ CONVERTIR A JSON PARA ENVIAR A SUPABASE (crear/actualizar)
  // No incluye 'id' porque Supabase lo genera/identifica solo.
  Map<String, dynamic> toJson() {
    return {
      'nombre_producto': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'estado': estado,
    };
  }

  // ✅ COPIAR CON CAMBIOS (útil para editar sin mutar el original)
  Producto copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagen,
    String? categoria,
    bool? estado,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
    );
  }
}