// lib/services/pse_service.dart
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class BancoPse {
  final String codigo;
  final String nombre;
  BancoPse({required this.codigo, required this.nombre});
}

class PseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Lista de bancos habilitados para PSE (puedes ampliarla o
  /// consultarla dinámicamente al endpoint de ePayco si prefieres).
  static List<BancoPse> obtenerBancos() {
    return [
      BancoPse(codigo: '1007', nombre: 'Bancolombia'),
      BancoPse(codigo: '1051', nombre: 'Davivienda'),
      BancoPse(codigo: '1001', nombre: 'Banco de Bogotá'),
      BancoPse(codigo: '1023', nombre: 'Banco de Occidente'),
      BancoPse(codigo: '1006', nombre: 'Banco Corpbanca'),
      BancoPse(codigo: '1013', nombre: 'BBVA Colombia'),
      BancoPse(codigo: '1002', nombre: 'Banco Popular'),
      BancoPse(codigo: '1019', nombre: 'Scotiabank Colpatria'),
      BancoPse(codigo: '1040', nombre: 'Banco Agrario'),
      BancoPse(codigo: '1032', nombre: 'Banco Caja Social'),
      BancoPse(codigo: '1060', nombre: 'Nequi'),
      BancoPse(codigo: '1801', nombre: 'Daviplata'),
    ];
  }

  /// Llama a la Edge Function y devuelve la URL bancaria a abrir en WebView
  static Future<Map<String, dynamic>> crearPagoPse({
    required String banco,
    required String tipoDocumento,
    required String numeroDocumento,
    required String tipoPersona, // '0' natural, '1' jurídica
    required String nombreCompleto,
    required String correo,
    required String telefono,
    required String direccion,
    required double total,
    required int idPedido,
  }) async {
    final response = await _supabase.functions.invoke(
      'crear-pago-pse',
      body: {
        'banco': banco,
        'tipoDocumento': tipoDocumento,
        'numeroDocumento': numeroDocumento,
        'tipoPersona': tipoPersona,
        'nombreCompleto': nombreCompleto,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'total': total,
        'idPedido': idPedido,
        'urlRespuesta': 'https://tu-dominio.com/respuesta-pago',
        'urlConfirmacion': 'https://tu-dominio.com/confirmacion-pago',
      },
    );

    if (response.status != 200) {
      throw Exception('Error al crear el pago PSE: ${response.data}');
    }

    return jsonDecode(response.data is String ? response.data : jsonEncode(response.data));
  }
}