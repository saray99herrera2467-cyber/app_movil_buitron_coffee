import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoAdminProvider extends ChangeNotifier {
  List<Producto> productos = [];
  bool cargando = false;
  String? error;

  // ✅ OBTENER TODOS LOS PRODUCTOS
  Future<void> cargarProductos() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      productos = await ProductoService.obtenerTodos();
    } catch (e) {
      error = 'Error al cargar productos: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // ✅ CREAR PRODUCTO
  Future<bool> crearProducto(Producto producto) async {
    try {
      await ProductoService.crearProducto(producto);
      await cargarProductos();
      return true;
    } catch (e) {
      error = 'Error al crear producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ ACTUALIZAR PRODUCTO
  Future<bool> actualizarProducto(Producto producto) async {
    try {
      await ProductoService.actualizarProducto(producto);
      await cargarProductos();
      return true;
    } catch (e) {
      error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ ELIMINAR PRODUCTO
  Future<bool> eliminarProducto(int id) async {
    try {
      await ProductoService.eliminarProducto(id);
      productos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ ACTIVAR / DESACTIVAR RÁPIDO
  Future<bool> cambiarEstado(Producto producto) async {
    final actualizado = producto.copyWith(estado: !producto.estado);
    return await actualizarProducto(actualizado);
  }
}
