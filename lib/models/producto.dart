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
    this.categoria = '',
    this.estado = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    // ID
    int id = 0;

    if (json['id'] is int) {
      id = json['id'];
    } else {
      id = int.tryParse('${json['id']}') ?? 0;
    }

    // NOMBRE
    final String nombre =
    (json['nombre'] ??
        json['nombre_producto'] ??
        json['producto'] ??
        '')
        .toString();

    // DESCRIPCIÓN
    String? descripcion;

    if (json['descripcion'] != null) {
      descripcion = json['descripcion'].toString();
    } else if (json['descripción'] != null) {
      descripcion = json['descripción'].toString();
    }

    // PRECIO
    double precio = 0.0;

    if (json['precio'] is num) {
      precio = (json['precio'] as num).toDouble();
    } else {
      precio = double.tryParse(
        '${json['precio']}'.replaceAll(',', '.'),
      ) ??
          0.0;
    }

    // IMAGEN
    String? imagen;

    if (json['imagen'] != null) {
      final valorImagen = json['imagen'].toString().trim();

      if (valorImagen.isNotEmpty) {
        imagen = valorImagen;
      }
    }

    // CATEGORÍA
    final String categoria =
    (json['categoria'] ??
        json['categoría'] ??
        json['category'] ??
        '')
        .toString();

    // ESTADO
    bool estado = true;

    if (json['estado'] is bool) {
      estado = json['estado'];
    } else if (json['estado'] != null) {
      final valor = json['estado'].toString().toLowerCase();

      estado = valor != 'false' &&
          valor != '0' &&
          valor != 'inactivo';
    }

    return Producto(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      precio: precio,
      imagen: imagen,
      categoria: categoria,
      estado: estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'estado': estado,
    };
  }

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