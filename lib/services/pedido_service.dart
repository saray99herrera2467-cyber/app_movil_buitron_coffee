import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'auth_service.dart';

class PedidoService {
  static final _supabase = ApiService.supabase;

  // ============================================================
  // CLIENTE: CREAR PEDIDO
  // ============================================================
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
    try {
      final int? idUsuario = await AuthService.obtenerIdSesion();
      if (idUsuario == null) throw Exception('No hay sesión activa');

      final DateTime ahora = DateTime.now();
      final DateTime fechaLimite = ahora.add(const Duration(hours: 24));

      final pedidoRes = await _supabase
          .from(ApiService.tablaPedidos)
          .insert({
            'id_usuario': idUsuario,
            'fecha': ahora.toIso8601String(),
            'subtotal': subtotal,
            'total': total,
            'estado': 'PENDIENTE',
            'fecha_limite': fechaLimite.toIso8601String(),
            'pagado': false,
            'metodo_pago': metodoPago,
          })
          .select()
          .single();

      final int idPedido = pedidoRes['id'];

      final List<Map<String, dynamic>> detalles = items.map((item) {
        return {
          'id_pedido': idPedido,
          'id_producto': item['id_producto'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio_unitario'],
        };
      }).toList();

      await _supabase.from(ApiService.tablaDetallePedido).insert(detalles);

      return pedidoRes;
    } catch (e) {
      debugPrint('❌ Error al crear pedido: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: OBTENER TODOS LOS PEDIDOS
  // ============================================================
  static Future<List<dynamic>> obtenerTodosAdmin() async {
    try {
      return await _supabase
          .from(ApiService.tablaPedidos)
          .select('*, usuario(*)')
          .order('id', ascending: false);
    } catch (e) {
      debugPrint('❌ Error obteniendo pedidos admin: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: ACTUALIZAR ESTADO
  // ============================================================
  static Future<void> actualizarEstado(int id, String nuevoEstado) async {
    try {
      await _supabase
          .from(ApiService.tablaPedidos)
          .update({'estado': nuevoEstado.toUpperCase()})
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error actualizando estado pedido: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: OBTENER DETALLE CON PRODUCTOS
  // ============================================================
  static Future<List<dynamic>> obtenerDetalleConProductos(int idPedido) async {
    try {
      return await _supabase
          .from(ApiService.tablaDetallePedido)
          .select('*, id_producto(*)')
          .eq('id_pedido', idPedido);
    } catch (e) {
      debugPrint('❌ Error obteniendo detalle admin: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: ACTUALIZAR SEGUIMIENTO
  // ============================================================
  static Future<void> actualizarSeguimiento(int id, String guia, String transportadora) async {
    try {
      await _supabase
          .from(ApiService.tablaPedidos)
          .update({
            'numero_guia': guia,
            'transportadora': transportadora,
            'estado': 'EN CAMINO',
          })
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error actualizando seguimiento: $e');
      rethrow;
    }
  }
}
