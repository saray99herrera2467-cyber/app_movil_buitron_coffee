import 'package:flutter/foundation.dart';
import '../models/producto.dart';

class CarritoProvider with ChangeNotifier {
  // ============================================================
  // PRODUCTOS DEL CARRITO
  // ============================================================

  final List<Producto> _items = [];

  // Como Producto.id es int, aquí también usamos int
  final Map<int, int> _cantidades = {};

  // ============================================================
  // GETTERS
  // ============================================================

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
  String? agregarProducto(Producto producto) {
    final int id = producto.id;
    final int cantidadActual = _cantidades[id] ?? 0;

    // Verificar si hay stock disponible
    if (cantidadActual >= producto.stock) {
      return 'Lo sentimos, no hay más unidades disponibles de este café.';
    }

    if (_cantidades.containsKey(id)) {
      // Ya existe → aumentar cantidad
      _cantidades[id] = cantidadActual + 1;
    } else {
      // Producto nuevo
      _items.add(producto);
      _cantidades[id] = 1;
    }

    notifyListeners();
    return null;
  }

  // ============================================================
  // MÉTODO ALTERNATIVO PARA AGREGAR
  // ============================================================

  String? agregar(Producto producto) {
    return agregarProducto(producto);
  }

  // ============================================================
  // CAMBIAR CANTIDAD
  // ============================================================

  String? cambiarCantidad(int productoId, int cantidad) {
    // Si la cantidad llega a cero, eliminamos el producto
    if (cantidad <= 0) {
      eliminarProducto(productoId);
      return null;
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

    _cantidades[productoId] = cantidad;

    notifyListeners();
    return null;
  }

  // ============================================================
  // AUMENTAR CANTIDAD
  // ============================================================

  String? aumentarCantidad(int productoId) {
    final cantidadActual = _cantidades[productoId] ?? 1;

    return cambiarCantidad(
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

  void eliminarProducto(int productoId) {
    _items.removeWhere(
          (producto) => producto.id == productoId,
    );

    _cantidades.remove(productoId);

    notifyListeners();
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

  void limpiarCarrito() {
    _items.clear();
    _cantidades.clear();

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
