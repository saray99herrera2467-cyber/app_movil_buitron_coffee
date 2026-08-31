import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';

class ProductoAdminProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ⚠️ Verifica que este sea el nombre exacto de tu tabla en Supabase
  static const String _tabla = 'productos';

  List<Producto> productos = [];
  bool cargando = false;
  String? error;

  // ✅ OBTENER TODOS LOS PRODUCTOS
  Future<void> cargarProductos() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final data =
      await _supabase.from(_tabla).select().order('id', ascending: true);

      productos =
          (data as List).map((json) => Producto.fromJson(json)).toList();
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
      await _supabase.from(_tabla).insert(producto.toJson());
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
      await _supabase
          .from(_tabla)
          .update(producto.toJson())
          .eq('id', producto.id);
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
      await _supabase.from(_tabla).delete().eq('id', id);
      productos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ ACTIVAR / DESACTIVAR RÁPIDO (sin eliminar)
  Future<bool> cambiarEstado(Producto producto) async {
    final actualizado = producto.copyWith(estado: !producto.estado);
    return await actualizarProducto(actualizado);
  }
}