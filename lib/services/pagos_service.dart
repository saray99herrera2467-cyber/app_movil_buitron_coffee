import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class PedidoService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<int?> _obtenerIdUsuarioActual() async {
    final correo = await AuthService.obtenerCorreoSesion();
    if (correo == null) return null;

    try {
      final respuesta = await _supabase
          .from('usuario')
          .select('id, nombre_usuario, apellido, telefono, direccion')
          .eq('correo', correo)
          .maybeSingle();
      return respuesta?['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> obtenerDatosUsuario() async {
    final correo = _supabase.auth.currentUser?.email;
    if (correo == null) return null;

    try {
      return await _supabase
          .from('usuario')
          .select()
          .eq('correo', correo)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> crearPedido({
    required String correo,
    required String nombreCompleto,
    required String telefono,
    required String direccion,
    required String metodoPago,
    required String? numeroPago,
    required double subtotal,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final idUsuario = await _obtenerIdUsuarioActual();
    if (idUsuario == null) return null;

    try {
      final pedidoRespuesta = await _supabase.from('pedido').insert({
        'id_usuario': idUsuario,
        'fecha': DateTime.now().toIso8601String(),
        'subtotal': subtotal,
        'total': total,
        'estado': 'PENDIENTE',
        'fecha_limite': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      }).select().single();

      final idPedido = pedidoRespuesta['id'];

      for (var item in items) {
        await _supabase.from('detalle_pedido').insert({
          'id_pedido': idPedido,
          'id_producto': item['id_producto'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio_unitario'],
        });
      }

      return pedidoRespuesta;
    } catch (e) {
      print('Error al crear pedido: $e');
      return null;
    }
  }
}