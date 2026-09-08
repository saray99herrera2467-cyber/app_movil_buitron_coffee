import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  static final _supabase = ApiService.supabase;

  // ============================================================
  // OBTENER TODOS LOS PRODUCTOS
  // ============================================================

  static Future<List<Producto>> obtenerTodos() async {
    try {
      final datos = await _supabase
          .from(ApiService.tablaProductos)
          .select()
          .order('id', ascending: true);

      return (datos as List)
          .map(
            (json) => Producto.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      rethrow;
    }
  }

  // ============================================================
  // OBTENER PRODUCTO POR ID
  // ============================================================

  static Future<Producto> obtenerPorId(int id) async {
    try {
      final datos = await _supabase
          .from(ApiService.tablaProductos)
          .select()
          .eq('id', id)
          .single();

      return Producto.fromJson(
        Map<String, dynamic>.from(datos),
      );
    } catch (e) {
      print('❌ Error obteniendo producto $id: $e');
      rethrow;
    }
  }

  // ============================================================
  // OBTENER PRODUCTOS POR CATEGORÍA
  // ============================================================

  static Future<List<Producto>> obtenerPorCategoria(
      String categoria,
      ) async {
    try {
      final datos = await _supabase
          .from(ApiService.tablaProductos)
          .select()
          .eq('categoria', categoria)
          .order('id', ascending: true);

      return (datos as List)
          .map(
            (json) => Producto.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } catch (e) {
      print(
        '❌ Error obteniendo categoría $categoria: $e',
      );
      rethrow;
    }
  }

  // ============================================================
  // BUSCAR PRODUCTOS
  // ============================================================

  static Future<List<Producto>> buscar(
      String texto,
      ) async {
    try {
      final datos = await _supabase
          .from(ApiService.tablaProductos)
          .select()
          .ilike(
        'nombre_producto',
        '%$texto%',
      )
          .order('id', ascending: true);

      return (datos as List)
          .map(
            (json) => Producto.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } catch (e) {
      print(
        '❌ Error buscando producto: $e',
      );
      rethrow;
    }
  }
}
