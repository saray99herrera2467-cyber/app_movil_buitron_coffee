import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Cliente de Supabase
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

  // Tablas de Supabase
  static const String tablaUsuarios = 'usuario';
  static const String tablaProductos = 'producto';
  static const String tablaCarrito = 'carrito';
  static const String tablaPedidos = 'pedido';
  static const String tablaDetallePedido = 'detalle_pedido';
  static const String tablaResenas = 'resenas';
}