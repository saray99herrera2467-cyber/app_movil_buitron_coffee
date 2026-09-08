import 'api_service.dart';

class PqrsService {
  static final _supabase = ApiService.supabase;

  // 📋 Obtener todas las PQRS (para el admin)
  static Future<List<dynamic>> obtenerTodas() async {
    return await _supabase
        .from(ApiService.tablaPqrs)
        .select()
        .order('frecha_creacion', ascending: false);
  }

  // ✍️ Enviar una nueva PQRS
  static Future<void> enviarPqrs(Map<String, dynamic> datos) async {
    await _supabase.from(ApiService.tablaPqrs).insert(datos);
  }

  // 🔄 Actualizar estado de una PQRS
  static Future<void> actualizarEstado(String codigoRef, String nuevoEstado) async {
    await _supabase
        .from(ApiService.tablaPqrs)
        .update({
          'estado': nuevoEstado,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        })
        .eq('codigo_referencia', codigoRef);
  }
}
