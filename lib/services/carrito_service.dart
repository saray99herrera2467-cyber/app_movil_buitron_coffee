import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class CarritoService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 📌 Obtener ID del usuario actual desde SharedPreferences y base de datos de manera robusta
  static Future<int?> _obtenerIdUsuarioActual() async {
    return await AuthService.obtenerIdSesion();
  }

  // 🛒 OBTENER CARRITO
  static Future<List<dynamic>> obtenerCarrito() async {
    final idUsuario = await _obtenerIdUsuarioActual();
    if (idUsuario == null) return [];

    try {
      final respuesta = await _supabase
          .from('carrito')
          .select('*, producto(*)')
          .eq('id_usuario', idUsuario);

      return respuesta;
    } catch (e) {
      debugPrint('Error al cargar carrito: $e');
      return [];
    }
  }

  // ➕ AGREGAR AL CARRITO
  static Future<bool> agregarAlCarrito(int idProducto, int cantidad) async {
    final idUsuario = await _obtenerIdUsuarioActual();
    if (idUsuario == null) return false;

    try {
      // Verificar si ya existe
      final existe = await _supabase
          .from('carrito')
          .select()
          .eq('id_usuario', idUsuario)
          .eq('id_producto', idProducto)
          .maybeSingle();

      if (existe != null) {
        // ✅ Sumar cantidad
        int cantidadActual = existe['cantidad'] ?? 0;
        await _supabase
            .from('carrito')
            .update({'cantidad': cantidadActual + cantidad})
            .eq('id', existe['id']);
      } else {
        // ✅ Insertar nuevo
        await _supabase.from('carrito').insert({
          'id_usuario': idUsuario,
          'id_producto': idProducto,
          'cantidad': cantidad,
          'fecha_agregado': DateTime.now().toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('Error al agregar: $e');
      return false;
    }
  }

  // 🔄 ACTUALIZAR CANTIDAD
  static Future<bool> actualizarCantidad(int idCarrito, int nuevaCantidad) async {
    try {
      if (nuevaCantidad <= 0) {
        return await eliminarDelCarrito(idCarrito);
      }

      await _supabase
          .from('carrito')
          .update({'cantidad': nuevaCantidad})
          .eq('id', idCarrito);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 🗑️ ELIMINAR DEL CARRITO
  static Future<bool> eliminarDelCarrito(int idCarrito) async {
    try {
      await _supabase.from('carrito').delete().eq('id', idCarrito);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 🧹 VACIAR CARRITO
  static Future<bool> vaciarCarrito() async {
    final idUsuario = await _obtenerIdUsuarioActual();
    if (idUsuario == null) return false;

    try {
      await _supabase
          .from('carrito')
          .delete()
          .eq('id_usuario', idUsuario);
      return true;
    } catch (e) {
      return false;
    }
  }
}