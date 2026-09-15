import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/carrito_service.dart';

class CarritoProvider with ChangeNotifier {
  // ============================================================
  // PRODUCTOS DEL CARRITO
  // ============================================================

  final List<Producto> _items = [];

  // Como Producto.id es int, aquí también usamos int
  final Map<int, int> _cantidades = {};

  // Mapeo para guardar el ID de la fila en la tabla 'carrito' de Supabase
  final Map<int, int> _idsCarrito = {};

  // ============================================================
  // CARGAR DESDE NUBE
  // ============================================================

  Future<void> cargarCarritoDesdeServicio() async {
    try {
      final data = await CarritoService.obtenerCarrito();
      
      _items.clear();
      _cantidades.clear();
      _idsCarrito.clear();

      for (var row in data) {
        final prodJson = row['producto'];
        if (prodJson != null) {
          final prod = Producto.fromJson(Map<String, dynamic>.from(prodJson));
          _items.add(prod);
          _cantidades[prod.id] = row['cantidad'] ?? 1;
          _idsCarrito[prod.id] = row['id'];
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error sincronizando carrito: $e');
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================
// ... (rest of the getters remain similar)

  List<Producto> get items => List.unmodifiable(_items);

  Map<int, int> get cantidades => Map.unmodifiable(_cantidades);

  // ============================================================
  // CANTIDAD TOTAL DE PRODUCTOS
  // ============================================================

  int get cantidadTotal {
    int total = 0;

    for (final producto in _items) {
      total += _cantidades[producto.id] ?? 1;
    }

    return total;
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double get subtotal {
    double total = 0;

    for (final producto in _items) {
      final cantidad = _cantidades[producto.id] ?? 1;

      total += producto.precio * cantidad;
    }

    return total;
  }

  // ============================================================
  // COSTO DE ENVÍO
  // ============================================================

  double get costoEnvio {
    if (_items.isEmpty) {
      return 0;
    }

    // Envío gratis si la compra supera $100.000
    if (subtotal > 100000) {
      return 0;
    }

    return 15000;
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double get total {
    return subtotal + costoEnvio;
  }

  // ============================================================
  // AGREGAR PRODUCTO
  // ============================================================

  /// Agrega un producto al carrito.
  /// Devuelve un String con el error si supera el stock, o null si fue exitoso.
  Future<String?> agregarProducto(Producto producto) async {
    final int id = producto.id;
    final int cantidadActual = _cantidades[id] ?? 0;

    // Verificar si hay stock disponible
    if (cantidadActual >= producto.stock) {
      return 'Lo sentimos, no hay más unidades disponibles de este café.';
    }

    // ✅ Sincronizar con Supabase
    final exito = await CarritoService.agregarAlCarrito(id, 1);
    if (!exito) return 'Error al conectar con la base de datos';

    if (_cantidades.containsKey(id)) {
      _cantidades[id] = cantidadActual + 1;
    } else {
      _items.add(producto);
      _cantidades[id] = 1;
    }

    notifyListeners();
    // Refrescamos IDs de carrito para asegurar consistencia
    await cargarCarritoDesdeServicio(); 
    return null;
  }

  // ============================================================
  // MÉTODO ALTERNATIVO PARA AGREGAR
  // ============================================================

  Future<String?> agregar(Producto producto) async {
    return await agregarProducto(producto);
  }

  // ============================================================
  // CAMBIAR CANTIDAD
  // ============================================================

  Future<String?> cambiarCantidad(int productoId, int cantidad) async {
    // Si la cantidad llega a cero, eliminamos el producto
    if (cantidad <= 0) {
      return await eliminarProducto(productoId);
    }

    // Buscamos el producto en el carrito para conocer su stock
    final producto = _items.firstWhere(
      (p) => p.id == productoId,
      orElse: () => Producto(id: -1, nombre: '', precio: 0),
    );

    if (producto.id == -1) return 'Producto no encontrado';

    // Verificar contra el stock
    if (cantidad > producto.stock) {
      return 'Solo quedan ${producto.stock} unidades disponibles.';
    }

    // ✅ Sincronizar con Supabase
    final idCarrito = _idsCarrito[productoId];
    if (idCarrito != null) {
      final exito = await CarritoService.actualizarCantidad(idCarrito, cantidad);
      if (!exito) return 'Error al actualizar en la nube';
    }

    _cantidades[productoId] = cantidad;
    notifyListeners();
    return null;
  }

  // ============================================================
  // AUMENTAR CANTIDAD
  // ============================================================

  Future<String?> aumentarCantidad(int productoId) async {
    final cantidadActual = _cantidades[productoId] ?? 1;

    return await cambiarCantidad(
      productoId,
      cantidadActual + 1,
    );
  }

  // ============================================================
  // DISMINUIR CANTIDAD
  // ============================================================

  void disminuirCantidad(int productoId) {
    final cantidadActual = _cantidades[productoId] ?? 1;

    cambiarCantidad(
      productoId,
      cantidadActual - 1,
    );
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  Future<String?> eliminarProducto(int productoId) async {
    final idCarrito = _idsCarrito[productoId];
    if (idCarrito != null) {
      await CarritoService.eliminarDelCarrito(idCarrito);
    }

    _items.removeWhere(
          (producto) => producto.id == productoId,
    );

    _cantidades.remove(productoId);
    _idsCarrito.remove(productoId);

    notifyListeners();
    return null;
  }

  // ============================================================
  // QUITAR PRODUCTO
  // ============================================================

  void quitarProducto(int productoId) {
    eliminarProducto(productoId);
  }

  // ============================================================
  // LIMPIAR TODO EL CARRITO
  // ============================================================

  Future<void> limpiarCarrito() async {
    await CarritoService.vaciarCarrito();
    _items.clear();
    _cantidades.clear();
    _idsCarrito.clear();

    notifyListeners();
  }

  void limpiarCarritoLocal() {
    _items.clear();
    _cantidades.clear();
    _idsCarrito.clear();
    notifyListeners();
  }

  // ============================================================
  // SABER SI UN PRODUCTO ESTÁ EN EL CARRITO
  // ============================================================

  bool contieneProducto(int productoId) {
    return _items.any(
          (producto) => producto.id == productoId,
    );
  }

  // ============================================================
  // OBTENER CANTIDAD DE UN PRODUCTO
  // ============================================================

  int obtenerCantidad(int productoId) {
    return _cantidades[productoId] ?? 0;
  }
}
