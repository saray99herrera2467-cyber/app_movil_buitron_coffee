import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // CARGAR DATOS DEL USUARIO
  // ============================================================

  Future<Map<String, dynamic>?> cargarDatosUsuario(
      String correo,
      ) async {
    try {
      final respuesta = await _supabase
          .from('usuario')
          .select()
          .eq('correo', correo)
          .maybeSingle();

      return respuesta;
    } catch (e) {
      throw Exception('Error al cargar datos: $e');
    }
  }

  // ============================================================
  // ACTUALIZAR TABLA usuario
  // ============================================================

  Future<void> actualizarEnTabla({
    required String correo,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String documento,
  }) async {
    try {
      await _supabase
          .from('usuario')
          .update({
        'nombre_usuario': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'direccion': direccion,
        'documento': documento,
      })
          .eq('correo', correo);
    } catch (e) {
      throw Exception('Error al guardar en tabla: $e');
    }
  }

  // ============================================================
  // ACTUALIZAR DATOS EN AUTH
  // ============================================================

  Future<void> actualizarEnAuth({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String documento,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'nombre_usuario': nombre,
            'apellido': apellido,
            'telefono': telefono,
            'direccion': direccion,
            'documento': documento,
          },
        ),
      );
    } catch (e) {
      throw Exception(
        'Error al actualizar autenticación: $e',
      );
    }
  }

  // ============================================================
  // GUARDAR PERFIL COMPLETO
  // ============================================================

  Future<void> guardarPerfilCompleto({
    required String correo,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String documento,
  }) async {
    try {
      if (_supabase.auth.currentUser != null) {
        await actualizarEnAuth(
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          direccion: direccion,
          documento: documento,
        );
      }
    } catch (_) {}

    await actualizarEnTabla(
      correo: correo,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      direccion: direccion,
      documento: documento,
    );
  }
}