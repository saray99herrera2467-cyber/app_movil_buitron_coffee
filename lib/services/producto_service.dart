import '../models/producto.dart';
import 'api_service.dart';

class ProductoService {
  static final _supabase = ApiService.supabase;

  // 📋 Obtener todos los productos activos
  static Future<List<Producto>> obtenerTodos() async {
    final List<dynamic> datos = await _supabase
        .from(ApiService.tablaProductos)
        .select()
        .eq('estado', true)
        .order('id', ascending: true);

    return datos.map((json) => Producto.fromJson(json)).toList();
  }

  // 🔍 Obtener un producto por ID
  static Future<Producto> obtenerPorId(int id) async {
    final datos = await _supabase
        .from(ApiService.tablaProductos)
        .select()
        .eq('id', id)
        .single();

    return Producto.fromJson(datos);
  }

  // 📂 Obtener productos por categoría
  static Future<List<Producto>> obtenerPorCategoria(String categoria) async {
    final List<dynamic> datos = await _supabase
        .from(ApiService.tablaProductos)
        .select()
        .eq('categoria', categoria)
        .eq('estado', true)
        .order('id', ascending: true);

    return datos.map((json) => Producto.fromJson(json)).toList();
  }

  // 🔎 Buscar productos por nombre
  static Future<List<Producto>> buscar(String texto) async {
    final List<dynamic> datos = await _supabase
        .from(ApiService.tablaProductos)
        .select()
        .ilike('nombre_producto', '%$texto%')
        .eq('estado', true)
        .order('nombre_producto', ascending: true);

    return datos.map((json) => Producto.fromJson(json)).toList();
  }
}