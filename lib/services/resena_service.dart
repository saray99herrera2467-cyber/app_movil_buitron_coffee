import '../models/resena.dart';
import 'api_service.dart';

class ResenaService {
  static final _supabase = ApiService.supabase;

  // ⭐ Obtener todas las reseñas de un producto
  static Future<List<ResenaModel>> obtenerResenasPorProducto(int productoId) async {
    final List<dynamic> datos = await _supabase
        .from(ApiService.tablaResenas)
        .select('*, usuario(*)')
        .eq('producto_id', productoId)
        .order('id', ascending: false);

    return datos.map((json) => ResenaModel.fromJson(json)).toList();
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