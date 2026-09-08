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

  void agregarProducto(Producto producto) {
    if (_cantidades.containsKey(producto.id)) {
      // Ya existe → aumentar cantidad
      _cantidades[producto.id] = (_cantidades[producto.id] ?? 0) + 1;
    } else {
      // Producto nuevo
      _items.add(producto);
      _cantidades[producto.id] = 1;
    }

    notifyListeners();
  }

  // ============================================================
  // MÉTODO ALTERNATIVO PARA AGREGAR
  // ============================================================

  void agregar(Producto producto) {
    agregarProducto(producto);
  }

  // ============================================================
  // CAMBIAR CANTIDAD
  // ============================================================

  void cambiarCantidad(int productoId, int cantidad) {
    // Si la cantidad llega a cero, eliminamos el producto
    if (cantidad <= 0) {
      eliminarProducto(productoId);
      return;
    }

    // Verificamos que el producto exista
    final existe = _items.any(
          (producto) => producto.id == productoId,
    );

    if (!existe) {
      return;
    }

    _cantidades[productoId] = cantidad;

    notifyListeners();
  }

  // ============================================================
  // AUMENTAR CANTIDAD
  // ============================================================

  void aumentarCantidad(int productoId) {
    final cantidadActual = _cantidades[productoId] ?? 1;

    cambiarCantidad(
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
