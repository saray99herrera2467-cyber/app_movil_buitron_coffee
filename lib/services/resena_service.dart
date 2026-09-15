import 'package:flutter/foundation.dart';
import '../models/resena.dart';
import 'api_service.dart';

class ResenaService {
  static final _supabase = ApiService.supabase;
  static const String _tabla = ApiService.tablaResenas;

  // ============================================================
  // CLIENTE: OBTENER RESEÑAS APROBADAS
  // ============================================================
  static Future<List<ResenaModel>> obtenerResenasAprobadasPorProducto(int productoId) async {
    try {
      final List<dynamic> datos = await _supabase
          .from(_tabla)
          .select('*, usuario(*)')
          .eq('producto_id', productoId)
          .eq('estado', 'aprobada')
          .order('id', ascending: false);

      return datos.map((json) => ResenaModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo reseñas aprobadas: $e');
      return [];
    }
  }

  // ============================================================
  // CLIENTE: AGREGAR RESEÑA
  // ============================================================
  static Future<ResenaModel> agregarResena(ResenaModel nuevaResena) async {
    final respuesta = await _supabase
        .from(_tabla)
        .insert(nuevaResena.toJson())
        .select()
        .single();

    return ResenaModel.fromJson(respuesta);
  }

  // ============================================================
  // ADMIN: OBTENER TODAS LAS RESEÑAS
  // ============================================================
  static Future<List<dynamic>> obtenerTodasAdmin() async {
    try {
      return await _supabase
          .from(_tabla)
          .select('*, producto(*), usuario(*)')
          .order('id', ascending: false);
    } catch (e) {
      debugPrint('❌ Error obteniendo todas las reseñas admin: $e');
      rethrow;
    }
  }

  // ============================================================
  // ADMIN: ACTUALIZAR ESTADO
  // ============================================================
  static Future<void> actualizarEstado(int id, String estado) async {
    try {
      await _supabase
          .from(_tabla)
          .update({'estado': estado})
          .eq('id', id);
    } catch (e) {
      debugPrint('❌ Error actualizando estado reseña: $e');
      rethrow;
    }
  }

  // 📊 Obtener promedio de calificación
  static Future<double> obtenerPromedioCalificacion(int productoId) async {
    final List<dynamic> datos = await _supabase
        .from(_tabla)
        .select('calificacion')
        .eq('producto_id', productoId);

    if (datos.isEmpty) return 0.0;

    double suma = 0.0;
    for (var item in datos) {
      suma += (item['calificacion'] as num? ?? 0).toDouble();
    }
    return suma / datos.length;
  }
}
