import 'package:flutter/foundation.dart';
import '../models/resena.dart';
import 'api_service.dart';

class ResenaService {
  static final _supabase = ApiService.supabase;

  // ⭐ Obtener reseñas aprobadas de un producto
  static Future<List<ResenaModel>> obtenerResenasAprobadasPorProducto(int productoId) async {
    try {
      final List<dynamic> datos = await _supabase
          .from(ApiService.tablaResenas)
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

  // ⭐ Obtener todas las reseñas de un producto (para debug o admin si se requiere)
  static Future<List<ResenaModel>> obtenerResenasPorProducto(int productoId) async {
    try {
      final List<dynamic> datos = await _supabase
          .from(ApiService.tablaResenas)
          .select('*, usuario(*)')
          .eq('producto_id', productoId)
          .order('id', ascending: false);

      return datos.map((json) => ResenaModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo todas las reseñas: $e');
      return [];
    }
  }

  // ✍️ Agregar una nueva reseña
  static Future<ResenaModel> agregarResena(ResenaModel nuevaResena) async {
    final respuesta = await _supabase
        .from(ApiService.tablaResenas)
        .insert(nuevaResena.toJson())
        .select()
        .single();

    return ResenaModel.fromJson(respuesta);
  }

  // 📊 Obtener promedio de calificación de un producto
  static Future<double> obtenerPromedioCalificacion(int productoId) async {
    final List<dynamic> datos = await _supabase
        .from(ApiService.tablaResenas)
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