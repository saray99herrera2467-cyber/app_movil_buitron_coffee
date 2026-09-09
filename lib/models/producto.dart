class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagen;
  final String categoria;
  final bool estado;
  final int stock;
  final double calificacionPromedio;
  final int totalResenas;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagen,
    this.categoria = '',
    this.estado = true,
    this.stock = 0,
    this.calificacionPromedio = 0.0,
    this.totalResenas = 0,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    // ID
    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else {
      id = int.tryParse('${json['id']}') ?? 0;
    }

    // NOMBRE (Soporta ambos para compatibilidad)
    final String nombre = (json['nombre_producto'] ?? 
                           json['nombre'] ?? 
                           json['producto'] ?? 
                           '').toString();

    // DESCRIPCIÓN
    String? descripcion = (json['descripcion'] ?? json['descripción'])?.toString();

    // PRECIO
    double precio = 0.0;
    if (json['precio'] is num) {
      precio = (json['precio'] as num).toDouble();
    } else {
      precio = double.tryParse('${json['precio']}'.replaceAll(',', '.')) ?? 0.0;
    }

    // IMAGEN
    String? imagen;
    final posiblesCamposImagen = ['imagen', 'url_imagen', 'foto', 'imagen_url', 'img'];
    for (final campo in posiblesCamposImagen) {
      if (json[campo] != null && json[campo].toString().trim().isNotEmpty) {
        imagen = json[campo].toString().trim();
        break;
      }
    }

    // CATEGORÍA
    final String categoria = (json['categoria'] ?? json['categoría'] ?? '').toString();

    // ESTADO
    bool estado = true;
    if (json['estado'] is bool) {
      estado = json['estado'];
    } else if (json['estado'] != null) {
      final valor = json['estado'].toString().toLowerCase();
      estado = valor != 'false' && valor != '0' && valor != 'inactivo';
    }

    // STOCK
    int stock = 0;
    if (json['stock'] is int) {
      stock = json['stock'];
    } else {
      stock = int.tryParse('${json['stock']}') ?? 0;
    }

    // CALIFICACIÓN Y RESEÑAS
    double calProm = 0.0;
    if (json['calificacion_promedio'] is num) {
      calProm = (json['calificacion_promedio'] as num).toDouble();
    }

    int totRes = 0;
    if (json['total_resenas'] is int) {
      totRes = json['total_resenas'];
    }

    return Producto(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      precio: precio,
      imagen: imagen,
      categoria: categoria,
      estado: estado,
      stock: stock,
      calificacionPromedio: calProm,
      totalResenas: totRes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_producto': nombre, // ✅ Mapeo correcto para Supabase
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'estado': estado,
      'stock': stock,
      // calificacion_promedio y total_resenas suelen ser calculados por la DB, 
      // pero los incluimos si es necesario enviarlos.
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
    int? stock,
    double? calificacionPromedio,
    int? totalResenas,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      stock: stock ?? this.stock,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      totalResenas: totalResenas ?? this.totalResenas,
    );
  }
}
