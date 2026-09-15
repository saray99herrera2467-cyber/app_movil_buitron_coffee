import 'package:flutter/foundation.dart';
import 'api_service.dart';

class PqrsService {
  static final _supabase = ApiService.supabase;
  static const String _tabla = ApiService.tablaPqrs;

  // ============================================================
  // CLIENTE: ENVIAR PQRS
  // ============================================================
  static Future<void> enviarPqrs(Map<String, dynamic> datos) async {
    try {
      await _supabase.from(_tabla).insert(datos);
    } catch (e) {
      debugPrint('❌ Error enviando PQRS: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: OBTENER TODAS LAS PQRS
  // ============================================================
  static Future<List<dynamic>> obtenerTodas() async {
    try {
      return await _supabase
          .from(_tabla)
          .select()
          .order('fecha_creacion', ascending: false);
    } catch (e) {
      debugPrint('❌ Error obteniendo PQRS admin: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: ACTUALIZAR RESPUESTA Y ESTADO
  // ============================================================
  static Future<void> actualizarRespuesta(String codigoRef, String nuevoEstado, String respuesta) async {
    try {
      await _supabase
          .from(_tabla)
          .update({
            'estado': nuevoEstado,
            'respuesta': respuesta,
            'fecha_actualizacion': DateTime.now().toIso8601String(),
          })
          .eq('codigo_referencia', codigoRef);
    } catch (e) {
      debugPrint('❌ Error actualizando PQRS admin: $e');
      rethrow;
    }
  }
}
