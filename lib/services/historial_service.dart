import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class HistorialService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 📌 Obtener ID del usuario actual desde sesión local
  static Future<int?> _obtenerIdUsuarioActual() async {
    final correo = await AuthService.obtenerCorreoSesion();
    if (correo == null) return null;

    try {
      final respuesta = await _supabase
          .from('usuario')
          .select('id')
          .eq('correo', correo)
          .maybeSingle();
      return respuesta?['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  // 📋 OBTENER TODOS LOS PEDIDOS DEL USUARIO
  static Future<List<dynamic>> obtenerPedidosUsuario() async {
    final idUsuario = await _obtenerIdUsuarioActual();
    if (idUsuario == null) return [];

    try {
      // 🔍 Traer pedidos del usuario ordenados por fecha (más recientes primero)
      final pedidos = await _supabase
          .from('pedido')
          .select()
          .eq('id_usuario', idUsuario)
          .order('fecha', ascending: false);

      return pedidos;
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
      return [];
    }
  }

  // 📦 OBTENER DETALLES DE UN PEDIDO ESPECÍFICO
  static Future<List<dynamic>> obtenerDetallePedido(int idPedido) async {
    try {
      final detalles = await _supabase
          .from('detalle_pedido')
          .select('*, producto(*)')
          .eq('id_pedido', idPedido);

      return detalles;
    } catch (e) {
      debugPrint('Error al cargar detalles: $e');
      return [];
    }
  }

  // 🗑️ ELIMINAR PEDIDO
  static Future<bool> eliminarPedido(int idPedido) async {
    try {
      // 1. Eliminar primero los detalles (por restricción de clave foránea)
      await _supabase
          .from('detalle_pedido')
          .delete()
          .eq('id_pedido', idPedido);

      // 2. Eliminar el encabezado del pedido
      await _supabase
          .from('pedido')
          .delete()
          .eq('id', idPedido);

      return true;
    } catch (e) {
      debugPrint('Error al eliminar pedido: $e');
      return false;
    }
  }
}
