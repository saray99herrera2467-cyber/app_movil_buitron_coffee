import 'package:flutter/foundation.dart';
import '../models/producto.dart';

class CarritoProvider with ChangeNotifier {
  List<Producto> _items = [];
  Map<String, int> _cantidades = {};

  List<Producto> get items => _items;
  Map<String, int> get cantidades => _cantidades;

  double get subtotal {
    double total = 0;
    for (var p in _items) {
      total += p.precio * (_cantidades[p.id] ?? 1);
    }
    return total;
  }

  double get costoEnvio => subtotal > 100000 ? 0 : 15000;
  double get total => subtotal + costoEnvio;

  void agregarProducto(Producto producto) {
    if (_cantidades.containsKey(producto.id)) {
      _cantidades[producto.id] = (_cantidades[producto.id]! + 1);
    } else {
      _items.add(producto);
      _cantidades[producto.id] = 1;
    }
    notifyListeners();
  }

  void cambiarCantidad(String productoId, int cantidad) {
    if (cantidad <= 0) {
      eliminarProducto(productoId);
      return;
    }
    _cantidades[productoId] = cantidad;
    notifyListeners();
  }

  void eliminarProducto(String productoId) {
    _items.removeWhere((p) => p.id == productoId);
    _cantidades.remove(productoId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _items.clear();
    _cantidades.clear();
    notifyListeners();
  }
}