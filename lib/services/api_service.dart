import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // ============================================================
  // CLIENTE DE SUPABASE
  // ============================================================

  static SupabaseClient? _cliente;

  static SupabaseClient get supabase {
    if (_cliente == null) {
      throw Exception(
        'Supabase no inicializado. '
            'Llama a ApiService.inicializarCliente()',
      );
    }

    return _cliente!;
  }

  static void inicializarCliente(
      SupabaseClient cliente,
      ) {
    _cliente = cliente;
  }

  // ============================================================
  // TABLAS DE SUPABASE
  // ============================================================

  static const String tablaUsuarios = 'usuario';

  // IMPORTANTE:
  // En Supabase tu tabla se llama "producto"
  static const String tablaProductos = 'producto';

  static const String tablaCarrito = 'carrito';

  static const String tablaPedidos = 'pedido';

  static const String tablaDetallePedido =
      'detalle_pedido';

  static const String tablaResenas = 'reseñas';

  static const String tablaPqrs = 'pqrs';
}