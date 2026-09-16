import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  static final _supabase = ApiService.supabase;
  static const String _tabla = 'producto'; // ✅ Nombre EXACTO de tu tabla

  // ============================================================
  // OBTENER PRODUCTOS ACTIVOS
  // ============================================================
  static Future<List<Producto>> obtenerActivos() async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .eq('estado', true)
          .order('id', ascending: true);

      return datos.map((json) {
        print("📋 Cargado: $json"); // Verifica qué llega
        return Producto.fromJson(json);
      }).toList();
    } catch (e) {
      print("❌ Error obtenerActivos: $e");
      rethrow;
    }
  }

  // ============================================================
  // OBTENER TODOS LOS PRODUCTOS
  // ============================================================
  static Future<List<Producto>> obtenerTodos() async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .order('id', ascending: true);

      return datos.map((json) {
        print("📋 Cargado: $json"); // Verifica qué llega
        return Producto.fromJson(json);
      }).toList();
    } catch (e) {
      print("❌ Error obtenerTodos: $e");
      rethrow;
    }
  }

  // ============================================================
  // OBTENER POR ID
  // ============================================================
  static Future<Producto> obtenerPorId(int id) async {
    try {
      final datos = await _supabase
          .from(_tabla)
          .select()
          .eq('id', id)
          .single();

      return Producto.fromJson(datos);
    } catch (e) {
      print("❌ Error obtenerPorId($id): $e");
      rethrow;
    }
  }

  // ============================================================
  // CREAR PRODUCTO
  // ============================================================
  static Future<void> crearProducto(Producto producto) async {
    try {
      final Map<String, dynamic> datos = {
        'nombre_producto': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'imagen': producto.imagen,
        'categoria': producto.categoria,
        'estado': producto.estado,
        'stock': producto.stock,
      };

      await _supabase.from(_tabla).insert(datos);
      print("✅ Creado: ${producto.nombre}");
    } catch (e) {
      print("❌ Error crear: $e");
      rethrow;
    }
  }

  // ============================================================
  // ACTUALIZAR PRODUCTO (Admin)
  // ============================================================
  static Future<void> actualizarProducto(Producto producto) async {
    try {
      final int idLimpio = producto.id;
      
      if (idLimpio <= 0) {
        throw Exception("ID de producto inválido para actualizar: $idLimpio");
      }

      final Map<String, dynamic> datos = {
        'nombre_producto': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'imagen': producto.imagen,
        'categoria': producto.categoria,
        'estado': producto.estado,
        'stock': producto.stock,
      };

      print("🚀 Intentando actualizar ID: $idLimpio en tabla: $_tabla");

      // Realizamos el update. No usamos .select().single() para evitar el error PGRST116
      // si por alguna razón de políticas de seguridad no devuelve la fila.
      await _supabase
          .from(_tabla)
          .update(datos)
          .eq('id', idLimpio);
          
      print("✅ Petición de actualización enviada correctamente.");
    } catch (e) {
      print("❌ Error crítico en actualizarProducto: $e");
      rethrow;
    }
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================
  static Future<void> eliminarProducto(int id) async {
    try {
      await _supabase.from(_tabla).delete().eq('id', id);
      print("✅ Eliminado: producto $id");
    } catch (e) {
      print("❌ Error eliminar($id): $e");
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

      return datos.map((json) => Producto.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error buscar: $e");
      rethrow;
    }
  }
}