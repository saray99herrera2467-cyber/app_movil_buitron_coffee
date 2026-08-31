import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 📌 Obtener ID del usuario con sesión activa (buscando por correo)
  static Future<int?> _obtenerIdUsuarioActual() async {
    final correo = _supabase.auth.currentUser?.email;
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
      print('Error al cargar pedidos: $e');
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
      print('Error al cargar detalles: $e');
      return [];
    }
  }
}