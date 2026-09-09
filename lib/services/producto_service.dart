import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  static final _supabase = ApiService.supabase;
  static const String _tabla = ApiService.tablaProductos;

  // ============================================================
  // OBTENER TODOS LOS PRODUCTOS
  // ============================================================
  static Future<List<Producto>> obtenerTodos() async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .order('id', ascending: true);

      return (datos as List)
          .map((json) => Producto.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // OBTENER PRODUCTO POR ID
  // ============================================================
  static Future<Producto> obtenerPorId(int id) async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .eq('id', id)
          .single();

      return Producto.fromJson(Map<String, dynamic>.from(datos));
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CREAR PRODUCTO (Admin)
  // ============================================================
  static Future<void> crearProducto(Producto producto) async {
    try {
      await _supabase.from(_tabla).insert(producto.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ACTUALIZAR PRODUCTO (Admin)
  // ============================================================
  static Future<void> actualizarProducto(Producto producto) async {
    try {
      final Map<String, dynamic> datos = producto.toJson();
      final int id = producto.id;
      // No enviamos el ID en el cuerpo de la actualización
      datos.remove('id'); 

      await _supabase
          .from(_tabla)
          .update(datos)
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ELIMINAR PRODUCTO (Admin)
  // ============================================================
  static Future<void> eliminarProducto(int id) async {
    try {
      await _supabase.from(_tabla).delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // BUSCAR PRODUCTOS
  // ============================================================
  static Future<List<Producto>> buscar(String texto) async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .ilike('nombre_producto', '%$texto%')
          .order('id', ascending: true);

      return (datos as List)
          .map((json) => Producto.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
