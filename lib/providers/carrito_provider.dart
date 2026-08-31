import 'package:flutter/foundation.dart';
import '../models/producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}

class CarritoProvider extends ChangeNotifier {
  List<ItemCarrito> items = [];

  int get cantidadTotal => items.fold(0, (sum, item) => sum + item.cantidad);
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  // ✅ AGREGAR PRODUCTO
  void agregarProducto(Producto prod) {
    int index = items.indexWhere((item) => item.producto.id == prod.id);
    if (index >= 0) {
      items[index].cantidad++;
    } else {
      items.add(ItemCarrito(producto: prod));
    }
    notifyListeners();
  }

  // ✅ CAMBIAR CANTIDAD
  void cambiarCantidad(int index, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      items.removeAt(index);
    } else {
      items[index].cantidad = nuevaCantidad;
    }
    notifyListeners();
  }

  // ✅ ELIMINAR PRODUCTO
  void eliminarProducto(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  // ✅ VACIAR CARRITO
  void vaciarCarrito() {
    items.clear();
    notifyListeners();
  }
}